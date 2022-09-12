#!/bin/python3 -B

import watchdog
import sys
import toml

def main():
  if len(sys.argv) != 2:
    print('[ERROR   ] Wrong numbers of parameters. Usage: {} <config.toml>'
        .format(sys.argv[0]))
    exit(1)

  config = toml.loads(open(sys.argv[1], 'r').read())

  def get_config(*name, **kwargs):
    c = config

    for n in name:
      if n in c:
        c = c[n]
      else:
        if 'default' in kwargs:
          return kwargs['default']
        else:
          raise ValueError('configure field "{}" not present'.format('.'.join(name))) 

    return c

  username = get_config('account', 'username')
  password = get_config('account', 'password')

  sender = get_config('email', 'sender')
  receiver = get_config('email', 'receiver')

  probe = get_config('check', 'probe', default='http://www.bing.com')
  tries = get_config('check', 'tries', default=3)
  timeout = get_config('check', 'timeout', default=5)
  interval = get_config('check', 'interval', default=5)

  watchdog.watchdog({
    'check': {
      'cmd': 'curl --retry {} --connect-timeout {} {}'.format(tries, timeout, probe),
      'interval': interval},
    'rise': [{
      'args': ['username', 'ip'],
      'cmd': 'echo "Your username is ${{username}}. Your ip is ${{ip}}" | mailx -s "[$(uname -n)] Network Reconnected" -r "{} ($(uname -n))" {}'.format(sender, receiver)}],
    'low': [{
      'ret': ['username', 'ip'],
      'cmd': '''
        result=$(curl -k -H "Content-Type: application/x-www-form-urlencoded" \\
          -X POST --cookie "JSESSIONID=D56359E00B58C7877668AAB44B3BFE31" \\
          --data "userName={}&password={}&hasValidateCode=false&authLan=zh_CN" \\
          https://controller.shanghaitech.edu.cn:8445/PortalServer//Webauth/webAuthAction\!login.action)
        
        success=$(echo "${{result}}" | sed "s/.*success\W*\(\w*\)\W*token.*/\\1/g")

        if [ "${{success}}"x = "true"x ]; then
          echo "${{result}}" | sed "s/.*\\"account\\":\s*\\"\(\w*\)\\".*\\"ip\\":\s*\\"\([0-9\.]*\)\\".*/{{\\"username\\":\\"\\1\\",\\"ip\\":\\"\\2\\"}}/g"
        else
          echo "${{result}}" | sed "s/.*message\W*\([^\\"]*\)\W*success.*/\\1/g"
          exit 1
        fi
      '''.format(username, password)}]
  })

if __name__ == '__main__':
  watchdog.app(main)
