#!/usr/bin/env bash
# Copyright: @indianets
# Usage: ./5glive.sh [interval]

# Check for adb device
if [ ! "$(adb devices | tail -n+2 | grep device)" ]; then
  echo "Connect a device to adb"
  exit 1
fi

# Clear lines
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

# Parse values and print
main() {
  line="$(adb logcat -b radio -d | grep 'CellSignalStrengthNr' | grep 'processCellInfo' | tail -1)"
  xdate="$(echo $line | cut -d' ' -f1-2)"
  pci="$(echo $line | sed -n -E 's/^.* mPci = (\S*) .*/\1/p')"
  tac="$(echo $line | sed -n -E 's/^.* mTac = (\S*) .*/\1/p')"
  band="$(echo $line | sed -n -E 's/^.* mBands = (\S*) .*/\1/p')"
  rsrp="$(echo $line | sed -n -E 's/^.* ssRsrp = (\S*) .*/\1/p')"
  rsrq="$(echo $line | sed -n -E 's/^.* ssRsrq = (\S*) .*/\1/p')"
  sinr="$(echo $line | sed -n -E 's/^.* ssSinr = (\S*) .*/\1/p')"

  if [[ "$oldrsrp" ]]; then
    trend="$(($oldrsrp - $rsrp))"
    rsrptrend=""
    if [[ "$trend" -gt 0 ]]; then
      rsrptrend="👎"
    elif [[ "$trend" -lt 0 ]]; then
      rsrptrend="👍"
    fi
  fi

  if [[ "$oldrsrq" ]]; then
    trend="$(($oldrsrq - $rsrq))"
    rsrqtrend=""
    if [[ "$trend" -gt 0 ]]; then
      rsrqtrend="👎"
    elif [[ "$trend" -lt 0 ]]; then
      rsrqtrend="👍"
    fi
  fi

  if [[ "$oldsinr" ]]; then
    trend="$(($oldsinr - $sinr))"
    sinrtrend=""
    if [[ "$trend" -gt 0 ]]; then
      sinrtrend="👎"
    elif [[ "$trend" -lt 0 ]]; then
      sinrtrend="👍"
    fi
  fi

  cls
  echo -e "TIME: $xdate\n"
  printf "BAND: %4s\tRSRP: %4d %s\n" "$band" "$rsrp" "$rsrptrend"
  printf "TAC : %4d\tRSRQ: %4d %s\n" "$tac" "$rsrq" "$rsrqtrend"
  printf "PCI : %4d\tSiNR: %4d %s\n" "$pci" "$sinr" "$sinrtrend"
  oldrsrp="$rsrp"
  oldrsrq="$rsrq"
  oldsinr="$sinr"
  sleep ${1:-.5}
}

clear
echo -e "================================"
echo -e "\tSIGNAL STRENGTH"
echo -e "================================"
echo -e "\n\n\n\n\n"
while (true); do
  main
done
