#!/bin/sh
# shellcheck disable=SC2059 disable=SC2034

# setup colors
# do we have tput?
if which 'tput' > /dev/null; then
  # do we have a terminal?
  if [ -t 1 ]; then
    # does the terminal have colors?
    ncolors=$(tput colors)
    if [ "$ncolors" -ge 8 ]; then
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
  system_swaptotal_mb=$(( system_swaptotal / 1024 ))
  system_root_fstotal=$(df /|grep -v Filesystem|awk '{print $2}')
  system_root_fstotal_mb=$(( system_root_fstotal / 1024 ))
  system_root_fsavail=$(df /|grep -v Filesystem|awk '{print $4}')
  system_root_fsavail_mb=$(( system_root_fsavail / 1024 ))
}

report_card () {
  system_info
  printf "${CYAN}          Total Real Memory:${GREEN} ${system_memtotal_mb}${NORMAL} MB\n"
  printf "${CYAN}          Total Swap Memory:${GREEN} ${system_swaptotal_mb}${NORMAL} MB\n"
  printf "${CYAN}      Total Disk Space On /:${GREEN} ${system_root_fstotal_mb}${NORMAL} MB\n"
  printf "${CYAN}  Available Disk Space on /:${GREEN} ${system_root_fsavail_mb}${NORMAL} MB\n"
  printf "${NORMAL}"
}

# Same as above, but receives suggested values for:
# Total memory and available disk space. Will calculate necessary disk Space
# on the assumption that a swap file can be created to satisfy memory needs.
report_card_suggestions () {
  system_info
  needed_mem=$1
  needed_mem_mb=$((needed_mem / 1024))
  needed_root_fs_avail=$2
  if [ -z "$1" ] || [ -z "$2" ]; then
    printf "${RED}Error:${NORMAL} Suggested memory and root filesystem sizes needed in function call.\n"
    return 1
  fi

  if [ "$needed_mem" -gt "$system_memtotal" ]; then
    printf "${CYAN}          Total Real Memory:${YELLOW} ${system_memtotal_mb}${NORMAL} MB (suggested: ⩾${RED}$needed_mem_mb${NORMAL} MB)\n"
  else
    printf "${CYAN}          Total Real Memory:${GREEN} ${system_memtotal_mb}${NORMAL} MB (OK: ⩾${CYAN}$needed_mem_mb${NORMAL} MB)\n"
  fi

  # Calculate needed swap, if we don't have enough memory.
  total_mem=$((system_memtotal + system_swaptotal))
  if [ "$needed_mem" -gt "$total_mem" ]; then
    needed_swap=$((needed_mem - total_mem)) # This is how much swap we need to add
  else
    needed_swap=$((needed_mem - system_memtotal))
  fi
  needed_swap_mb=$((needed_swap / 1024))
  if [ "$needed_swap" -lt 0 ]; then
    needed_swap=0
    needed_swap_mb=0
  fi
  if [ "$needed_mem" -gt "$total_mem" ]; then
    printf "${CYAN}          Total Swap Memory:${YELLOW} ${system_swaptotal_mb}${NORMAL} MB (suggest adding: ⩾${RED}${needed_swap_mb}${NORMAL} MB)\n"
  else
    printf "${CYAN}          Total Swap Memory:${GREEN} ${system_swaptotal_mb}${NORMAL} MB\n"
  fi

  printf "${CYAN}      Total Disk Space On /:${GREEN} ${system_root_fstotal_mb}${NORMAL} MB\n"

  needed_root_fs_avail=$((needed_root_fs_avail + needed_swap))
  needed_root_fs_avail_mb=$((needed_root_fs_avail / 1024))
  if [ "$needed_root_fs_avail" -gt "$system_root_fsavail" ]; then
    printf "${CYAN}  Available Disk Space on /:${YELLOW} ${system_root_fsavail_mb}${NORMAL} MB (suggested: ⩾${RED}${needed_root_fs_avail_mb}${NORMAL} MB)\n"
  else
    printf "${CYAN}  Available Disk Space on /:${GREEN} ${system_root_fsavail_mb}${NORMAL} MB (OK: ⩾${CYAN}${needed_root_fs_avail_mb}${NORMAL} MB)\n"
  fi
}
