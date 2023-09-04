#!/usr/bin/env bash

if [ ! -e .config.sh ]; then
  echo "Copy .config.sh-sample to .config.sh and edit accordingly!"
  exit 1
fi

. .config.sh

# Check for adb connection
if [ ! -z "$IP" ]; then
  adb connect $IP
fi

if [ ! "$(adb devices | tail -n+2 | grep device)" ]; then
  echo "connect a device to adb"
  exit 1
fi

# Get connection info and process
test -e radio-dump.old || touch radio-dump.old
adb logcat -b radio -d | grep 'CellSignalStrengthNr' | grep 'processCellInfo' >radio-dump
newlines="$(comm -13 radio-dump.old radio-dump)"
test -z "$newlines" && exit 0

# Process new log lines to output
test -e output.csv || echo "DATE,TIME,ARFCN,BAND,MCC,MNC,-,RSRP,RSRQ,SiNR" >output.csv

lastline="$(tail -1 radio-dump.old)"
echo "$newlines" | while read -r line; do
  if [ "$(echo $lastline | cut -d' ' -f 13-)" = "$(echo $line | cut -d' ' -f 13-)" ]; then
    echo "Ignoring unchanged values.."
  else
    echo "Parsing unique values.."
    xdate="$(echo $line | cut -d' ' -f1)"
    xtime="$(echo $line | cut -d' ' -f2)"
    arfcn="$(echo $line | sed -n -E 's/^.* mNrArfcn = (\S*) .*/\1/p')"
    band="$(echo $line | sed -n -E 's/^.* mBands = (\S*) .*/\1/p')"
    mcc="$(echo $line | sed -n -E 's/^.* mMcc = (\S*) .*/\1/p')"
    mnc="$(echo $line | sed -n -E 's/^.* mMnc = (\S*) .*/\1/p')"
    rsrp="$(echo $line | sed -n -E 's/^.* ssRsrp = (\S*) .*/\1/p')"
    rsrq="$(echo $line | sed -n -E 's/^.* ssRsrq = (\S*) .*/\1/p')"
    sinr="$(echo $line | sed -n -E 's/^.* ssSinr = (\S*) .*/\1/p')"
    echo "$xdate,$xtime,$arfcn,$band,$mcc,$mnc,,$rsrp,$rsrq,$sinr" | tee -a output.csv
  fi
  lastline="$line"
done

# Make dumps ready for next run
mv -f radio-dump radio-dump.old
echo "Done!"
