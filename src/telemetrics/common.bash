#!/bin/bash

#
# Common helper functions for telemetrics bundle tests
#

TELEMDCONFDIR="/etc/telemetrics"
TELEMDCONFILE="${TELEMDCONFDIR}/telemetrics.conf"
TELEMDMACHINEID="${TELEMDCONFDIR}/opt-in-static-machine-id"
TELEMSRC="../../src/telemetrics"
TELEMCONFSRC="${TELEMSRC}/telemetrics.conf"
TELEMOCKSRVR="${TELEMSRC}/mock-telemetrics-backend.sh"
TELEMUNITFLE="${TELEMSRC}/mock-telemetrics.service"
TELEMDSPOOL=/var/spool/telemetry
TELEMRECGEN=/usr/bin/telem-record-gen
KPAYLOAD=$'Lorem ipsum dolor sit amet, duo ferri malorum salutandi ex, sed ne req\n'
PAYLOAD_LINE_LEN=70
MACHINEID=/var/lib/telemetry/machine_id

keep_etc=1

# Setups a simple HTTP server as a service to emulate
# a remote telemetry backend
function setup_mock_backend() {
     mkdir -p /etc/systemd/system
     mkdir -p /etc/systemd/system/multi-user.target.wants
     cp ${TELEMUNITFLE} /etc/systemd/system/.
     ln -sf /etc/systemd/system/mock-telemetrics.service /etc/systemd/system/multi-user.target.wants/mock-telemetrics.service
     cp -p ${TELEMOCKSRVR} ${TELEMDCONFDIR}/mock-telemetrics-backend.sh
     systemctl daemon-reload
     systemctl start mock-telemetrics.service
}

# Removes mock telemetry backend server, unit files, and
# disables service
function teardown_mock_backend() {
     systemctl stop mock-telemetrics.service
     rm ${TELEMDCONFDIR}/mock-telemetrics-backend.sh
     rm /etc/systemd/system/multi-user.target.wants/mock-telemetrics.service
     rm /etc/systemd/system/mock-telemetrics.service
     systemctl daemon-reload
}

# Don't assume anything.
# Ensure all directories are created.
function telemetry_common_setup() {
     if [ ! -d "$TELEMDCONFDIR" ]; then
          mkdir -p ${TELEMDCONFDIR}
          touch ${TELEMDCONFDIR}/.bbtcreated
     else
         if [ -f "$TELEMDCONFILE" ]; then
             mv ${TELEMDCONFILE} ${TELEMDCONFILE}.bak
         fi
         if [ -f "$TELEMDMACHINEID" ]; then
             mv ${TELEMDMACHINEID} ${TELEMDMACHINEID}.bak
         fi
     fi
     telemctl opt-out
     setup_mock_backend
     telemctl opt-in
     update_telemd_conf
}

function telemetry_common_teardown() {
     teardown_mock_backend
     reset_telemd_conf
     if [ -f "$TELEMDCONFDIR/.bbtcreated" ]; then
         rm -rf ${TELEMDCONFDIR}
     else
         if [ -f "$TELEMDCONFILE.bak" ]; then
             mv ${TELEMDCONFILE}.bak ${TELEMDCONFILE}
         fi
         if [ -f "$TELEMDMACHINEID.bak" ]; then
             mv ${TELEMDMACHINEID}.bak ${TELEMDMACHINEID}
         fi
     fi
}

# Updates telemd configuration to point to emulated
# backend
function update_telemd_conf() {
     telemctl stop
     cp ${TELEMCONFSRC} ${TELEMDCONFDIR}/.
     systemctl start telemprobd.socket
     systemctl start telempostd.path
}

# Removes telemd custom configuration to emulated
# backend
function reset_telemd_conf() {
     telemctl stop
     systemctl daemon-reload
}

# Count mock server log lines that have "token"
# this lines will be present in the journal log
# only if the daemon posted the data to the
# backend
function received_count() {
     local token="${1}"
     # take first line in case this is a 'multiline' string
     token=$(echo "${token}" | cut -c1-${PAYLOAD_LINE_LEN})
     journalctl -u mock-telemetrics.service | grep "${token}" | wc -l
}

# Count log lines starting from since time stamp, to
# make sure data from event was received. To be used
# carefully and only when journal is lagging
function sync_received_count() {
     local token="${1}"
     local since="${2}"
     local flags=${3:-"-s"}
     for i in `seq 1 3`; do
         local count=$(journalctl --since "${since}" -u mock-telemetrics.service | grep "${flags}" "${token}" | wc -l)
         if [ "${count}" -gt 0 ]; then
             break
         fi
         sleep 1
     done
     echo $count
}

# Generates N lines of data for payload
#
function get_payload() {
     local N=${1:-10}
     local PAYLOAD=""
     for i in `seq 1 "${N}"`; do
         PAYLOAD="$PAYLOAD$KPAYLOAD"
     done
     echo "${PAYLOAD}"
}

# Set the value of machine id with a random value
#
function set_static_machine_id (){
     local machine_id=$(head -c 22 /dev/urandom | base64)
     echo $machine_id > ${TELEMDMACHINEID}
     echo $machine_id
}

# Returns machine id value
#
function cat_machine_id() {
     cat ${MACHINEID}
}

# Change file time stamp
#
function rewind_file_time() {
     local file2touch=$1
     local rewindby=$2
     touch -d "$rewindby" "$file2touch"
}

# Restart minimalistic telemetry services.
# Avoid running any probes as they could/would send
# additional data to backend and thus making any count of replies
# unpredictable.
#
function telemetry_restart_without_probes () {
     telemctl stop
     systemctl start telemprobd.socket
     systemctl start telempostd.path
}
