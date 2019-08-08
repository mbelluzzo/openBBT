#!/bin/bash

TELEM_JOURNAL_LOG="/var/log/telemetry/journal"

function wait_journal_inactive()
{
     for i in 1 2 3; do
          local starting_entries=$(cat ${TELEM_JOURNAL_LOG} | wc -l)
          sleep 1
          local ending_entries=$(cat ${TELEM_JOURNAL_LOG} | wc -l)
          [ $starting_entries -eq $ending_entries ] && break
     done
}

function count_journal_entries()
{
     EID=$1
     for i in 1 2 3; do
          if [ -f "${TELEM_JOURNAL_LOG}" ]; then
               break
          else
               if [ $i -eq 3 ]; then
                    echo -1
                    return
               fi
               sleep 1
          fi
     done

     wait_journal_inactive

     if [ ! -z "$EID" ]; then
          echo $(cat  ${TELEM_JOURNAL_LOG} | grep ${EID} | wc -l | awk '{print $1}')
     else
          echo $(wc -l ${TELEM_JOURNAL_LOG} | awk '{print $1}')
     fi
}

function insert_n_entries()
{
     N=$1
     EID=""
     if [ ! -z "$2" ]; then
          EID=" -e $2"
     fi

     for i in `seq 1 ${N}`; do
          telem-record-gen -p hello -c t/t/t ${EID}
     done
}
