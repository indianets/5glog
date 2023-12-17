#!/usr/bin/env bash

# Check for adb device
if [ ! "$(adb devices | tail -n+2 | grep device)" ]; then
  echo "Connect a device to adb"
  exit 1
fi

cls() {
  tput cuu1
  tput el
  tput cuu1
  tput el
  tput cuu1
  tput el
  tput cuu1
  tput el
  tput cuu1
  tput el
}

main() {
  line="$(adb logcat -b radio -d | grep 'CellSignalStrengthNr' | grep 'processCellInfo' | tail -1)"
  xdate="$(echo $line | cut -d' ' -f1-2)"
  pci="$(echo $line | sed -n -E 's/^.* mPci = (\S*) .*/\1/p')"
  tac="$(echo $line | sed -n -E 's/^.* mTac = (\S*) .*/\1/p')"
  band="$(echo $line | sed -n -E 's/^.* mBands = (\S*) .*/\1/p')"
  rsrp="$(echo $line | sed -n -E 's/^.* ssRsrp = (\S*) .*/\1/p')"
  rsrq="$(echo $line | sed -n -E 's/^.* ssRsrq = (\S*) .*/\1/p')"
  sinr="$(echo $line | sed -n -E 's/^.* ssSinr = (\S*) .*/\1/p')"

  cls
  echo -e "TIME: $xdate\n"
  echo -e "BAND:\t$band\t\tRSRP:\t$rsrp"
  echo -e "TAC:\t$tac\t\tRSRQ:\t$rsrq"
  echo -e "PCI:\t$pci\t\tSiNR:\t$sinr"
  sleep ${1:-.5}
}

clear
echo -e "\n\n\n\n"
while (true); do
  main
done
