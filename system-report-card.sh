#!/bin/sh

# setup colors
# do we have tput?
if type 'tput' > /dev/null; then
  # do we have a terminal?
  if [ -t 1 ]; then
    # does the terminal have colors?
    ncolors=$(tput colors)
    if [ $ncolors -ge 8 ]; then
      RED=$(tput setaf 1)
      GREEN=$(tput setaf 2)
      YELLOW=$(tput setaf 3)
      BLUE=$(tput setaf 4)
      MAGENTA=$(tput setaf 5)
      CYAN=$(tput setaf 6)
      WHITE=$(tput setaf 7)
      REDBG=$(tput setab 1)
      GREENBG=$(tput setab 2)
      YELLOWBG=$(tput setab 3)
      BLUEBG=$(tput setab 4)
      MAGENTABG=$(tput setab 5)
      CYANBG=$(tput setab 6)
      WHITEBG=$(tput setab 7)

      BOLD=$(tput bold)
      UNDERLINE=$(tput smul) # Many terminals don't support this
      NORMAL=$(tput sgr0)
    fi
  fi
else
  echo "tput not found, colorized output disabled."
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  MAGENTA=''
  CYAN=''
  WHITE=''
  REDBG=''
  GREENBG=''
  YELLOWBG=''
  BLUEBG=''
  MAGENTABG=''
  CYANBG=''

  BOLD=''
  UNDERLINE=''
  NORMAL=''
fi


system_info () {
  system_memtotal=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
  system_memtotal_mb=$(( system_memtotal / 1024 ))
  system_swaptotal=$(awk '/SwapTotal/ {print $2}' /proc/meminfo)
  system_swaptotal_mb=$(( system_memtotal / 1024 ))
  system_root_fstotal=$(df /|grep -v Filesystem|awk '{print $2}')
  system_root_fstotal_mb=$(( system_root_fstotal / 1024 ))
  system_root_fsavail=$(df /|grep -v Filesystem|awk '{print $4}')
  system_root_fsavail_mb=$(( system_root_fsavail / 1024 ))
}
report_card () {
  system_info
  printf "${CYAN}        Total Real Memory:${GREEN} ${system_memtotal_mb}${NORMAL} MB\n"
  printf "${CYAN}        Total Swap Memory:${GREEN} ${system_swaptotal_mb}${NORMAL} MB\n"
  printf "${CYAN}    Total Disk Space On /:${GREEN} ${system_root_fstotal_mb}${NORMAL} MB\n"
  printf "${CYAN}Available Disk Space on /:${GREEN} ${system_root_fsavail_mb}${NORMAL} MB\n"
  printf "${NORMAL}"
}
