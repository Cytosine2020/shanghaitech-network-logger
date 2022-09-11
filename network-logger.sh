#!/bin/sh

CONFIG=$1

HOST=$(uname -n)

read_config() {
  local num
  local result
  
  num=$#
  if [ "${num}" != "3" ] && [ "${num}" != "4" ]; then
    echo "[ERROR   ] internal error: read config wron number of parameters"
    exit 1
  fi

  result=$(python3 -c "import toml; print(toml.loads(open('${CONFIG}', 'r').read())['$2']['$3'])" 2> /dev/null)

  if [ -z ${result} ]; then
    if [ "${num}" = "4" ]; then
      result=$4
    else
      echo "[ERROR   ] configure field \"$2.$3\" not present"
      exit 1
    fi
  fi

  export $1=${result}
}

read_config USERNAME  account username
read_config PASSWORD  account password
read_config RECEIVER  email   receiver
read_config SENDER    email   sender
read_config PROBE     check   probe     http://www.bing.com
read_config TRIES     check   tries     3
read_config TIMEOUT   check   timeout   5
read_config INTERVAL  check   interval  60

login() {
  local num
  local result
  local success
  local error

  result=$(curl -s -k -H "Content-Type: application/x-www-form-urlencoded" \
      -X POST --cookie "JSESSIONID=D56359E00B58C7877668AAB44B3BFE31" \
      --data "userName=${USERNAME}&password=${PASSWORD}&hasValidateCode=false&authLan=zh_CN" \
      https://controller.shanghaitech.edu.cn:8445/PortalServer//Webauth/webAuthAction\!login.action)

  success=$(echo "${result}" | sed "s/.*success\W*\(\w*\)\W*token.*/\1/g")

  if [ "${success}"x = "true"x ]; then
    ip addr | mailx -s "Network Reconnected" -r "${SENDER} (${HOST})" ${RECEIVER}
    echo "[INFO    ] login success"
  else
    error=$(echo "${result}" | sed "s/.*message\W*\([^\"]*\)\W*success.*/\1/g")
    echo "[WARNING ] ${error}"
  fi
}

connect() {
  curl -s --retry ${TRIES} --connect-timeout ${TIMEOUT} ${PROBE}

  if [ $? -ne 0 ]; then
    echo "[WARNING ] detect offline"
    login
  fi
}

drop() {
  echo "[INFO    ] ================ [stop ] ================"
  exit 0
}

trap drop HUP INT TERM

echo "[INFO    ] ================ [start] ================"

while true; do
  connect
  sleep ${INTERVAL}
done

drop
