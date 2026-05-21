#! /bin/bash
WAYLAND_DISPLAY=wayland-1 wlr-randr --output HDMI-A-1 --custom-mode 800x600@60Hz

SOCKET_PATH="/tmp/openmsx-"${USER}
OPENMSX=`./openmsx-getstring.py --dir ${SOCKET_PATH}`
COMMAND=`echo ${OPENMSX} | awk '{ print $1 }'`
PROFILE=`echo ${OPENMSX} | awk '{ print $2 }'`

if [ "${COMMAND}" != "0xF1" ]; then
  echo "Not my command..."
  exit 0
fi

case "${PROFILE}" in
  
   "EXPERT3")   
     ./openmsx-shutdown.py --dir ${SOCKET_PATH}
     cp -f ./openmsx-profiles/EXPERT3.sh ./openmsx-profiles/default.sh
     cp -f ./openmsx-profiles/EXPERT3.system.sh ./openmsx-profiles/default.system.sh
     ./openmsx-profiles/EXPERT3.sh &
     sleep 5
     ./openmsx-start-binds.py --dir ${SOCKET_PATH}
     ;;

    "EXPERT1")
      ./openmsx-shutdown.py --dir ${SOCKET_PATH}
      cp -f ./openmsx-profiles/EXPERT1.sh ./openmsx-profiles/default.sh
      cp -f ./openmsx-profiles/EXPERT1.system.sh ./openmsx-profiles/default.system.sh
      ./openmsx-profiles/EXPERT1.sh &
      sleep 5
      ./openmsx-start-binds.py --dir ${SOCKET_PATH}
      ;;

    "EXPERT1EX")
      ./openmsx-shutdown.py --dir ${SOCKET_PATH}
      cp -f ./openmsx-profiles/EXPERT1EX.sh ./openmsx-profiles/default.sh
      cp -f ./openmsx-profiles/EXPERT1.system.sh ./openmsx-profiles/default.system.sh
      ./openmsx-profiles/EXPERT1EX.sh &
      sleep 5
      ./openmsx-start-binds.py --dir ${SOCKET_PATH}
      ;;

    "HOTBIT")
      ./openmsx-shutdown.py --dir ${SOCKET_PATH}
      cp -f ./openmsx-profiles/HOTBIT.sh ./openmsx-profiles/default.sh
      cp -f ./openmsx-profiles/HOTBIT.system.sh ./openmsx-profiles/default.system.sh
      ./openmsx-profiles/HOTBIT.sh &
      sleep 5
      ./openmsx-start-binds.py --dir ${SOCKET_PATH}
      ;;


    "HOTBITEX")
      ./openmsx-shutdown.py --dir ${SOCKET_PATH}
      cp -f ./openmsx-profiles/HOTBITEX.sh ./openmsx-profiles/default.sh
      cp -f ./openmsx-profiles/HOTBIT.system.sh ./openmsx-profiles/default.system.sh 
      ./openmsx-profiles/HOTBITEX.sh &
      sleep 5
      ./openmsx-start-binds.py --dir ${SOCKET_PATH}
      ;;


    *)
      ;;

 esac


