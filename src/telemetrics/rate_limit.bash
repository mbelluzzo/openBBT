#!/bin/bash

#
# Helper functions for bat-rate_limit and bat_spool_dir tests
#

# Deletes contents in telemetry spool directory
#
function clean_telemetry_spool() {
     rm -f ${TELEMDSPOOL}/*
}

# Returns the number of records spooled by telemd
# daemon
function spooled_count() {
     echo $(ls ${TELEMDSPOOL} | wc -l)
}

# Returns a count of spooled files but attempts
# to make the count stable
function stable_spooled_count() {
     local target=$1
     local count=-1
     for i in $(seq 1 3); do
          count=$(spooled_count)
          if [ "${count}" -eq "${target}" ]; then
                 break
          fi
          sleep 2
     done
     echo $count
}

# Update telemd rate configuration values
#
function enable_telemd_rate_limit_conf() {
     sed -i 's/byte_burst_limit=.*/byte_burst_limit=1/' ${TELEMDCONFILE}
     sed -i 's/byte_window_length=.*/byte_window_length=10/' ${TELEMDCONFILE}
     sed -i 's/record_burst_limit=.*/record_burst_limit=1/' ${TELEMDCONFILE}
     sed -i 's/record_window_length=.*/record_window_length=10/' ${TELEMDCONFILE}
     sed -i 's/rate_limit_enabled=false/rate_limit_enabled=true/' ${TELEMDCONFILE}
     sed -i 's/rate_limit_strategy=.*/rate_limit_strategy=spool/' ${TELEMDCONFILE}
}

# Set limiting strategy in configuration with
# given value (or spool if parameter is not provided)
function set_rate_limit_strategy() {
     local newvalue=${1:-"spool"}
     sed -i "s/rate_limit_strategy=.*/rate_limit_strategy=${newvalue}/" ${TELEMDCONFILE}
     telemetry_restart_without_probes
}

# Disable rate limiting
#
function disable_telemd_rate_limit() {
     sed -i 's/rate_limit_enabled=.*/rate_limit_enabled=false/' ${TELEMDCONFILE}
     telemetry_restart_without_probes
}

# Update telemd configuration to enable rate limiting
# option
function enable_telemd_rate_limit() {
     enable_telemd_rate_limit_conf
     telemetry_restart_without_probes
}

# Update byte and record burst limits
#
function update_telemd_byte_and_record() {
     local byte_limit=$1
     local recrd_limt=$2
     sed -i "s/byte_burst_limit=.*/byte_burst_limit=${byte_limit}/" ${TELEMDCONFILE}
     sed -i "s/record_burst_limit=.*/record_burst_limit=${recrd_limt}/" ${TELEMDCONFILE}
}

# Update telemd configuration byte burst limit
#
function update_telemd_byte_burst_limit() {
     enable_telemd_rate_limit_conf
     update_telemd_byte_and_record $1 -1
     telemetry_restart_without_probes
}

# Lower byte burst to a threshold of more or less
# one message
function decrease_byte_burst_limit() {
     update_telemd_byte_burst_limit 12
}

# Increase byte burst limit to a high threshold
# so multiple messages can pass
function increase_byte_burst_limit() {
    update_telemd_byte_burst_limit 20000
}

# Update telemd cofiguration record burst limit
#
function update_telemd_record_burst_limit() {
     enable_telemd_rate_limit_conf
     update_telemd_byte_and_record -1 2
     telemetry_restart_without_probes
}

# Update telemd configuration burst limits to make
# byte limit more sensitive than record limit
function update_telemd_byte_over_record() {
     enable_telemd_rate_limit_conf
     update_telemd_byte_and_record 10 20000
     telemetry_restart_without_probes
}

# Update telemd configuration burst limits to make
# record limit more sensitive than byte limit
function update_telemd_record_over_byte() {
     enable_telemd_rate_limit_conf
     update_telemd_byte_and_record 20000 2
     telemetry_restart_without_probes
}

# Sets the spool directory max size to a low
# threshold so a big message will be dropped
function set_low_spool_dir_limit() {
     update_telemd_byte_and_record -1 2
     sed -i "s/spool_max_size=.*/spool_max_size=2/" ${TELEMDCONFILE}
     telemetry_restart_without_probes
}

# Sets spool processing time to 120 seconds the
# lowest allowed time
function set_low_spool_process_time() {
     sed -i "s/spool_process_time=.*/spool_process_time=120/" ${TELEMDCONFILE}
     telemetry_restart_without_probes
}

# Sets expiration record to a minimum value
#
function set_low_record_expiration() {
     sed -i "s/record_expiry=.*/record_expiry=1/" ${TELEMDCONFILE}
     sed -i "s/spool_process_time=.*/spool_process_time=120/" ${TELEMDCONFILE}
}

# Using telem record gen to submit provided payload
# to daemon
function send_n_records() {
     local n=$1
     local p=$2
     for i in `seq 1 $n`; do
          $TELEMRECGEN -c $CLASS -p "$p"
     done
}
