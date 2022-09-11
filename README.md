# ShanghaiTech Network Logger

ShanghaiTech Network Logger works as a systemctl service. After the network connection is down, it login the network and sends the system IP address to your email account.

This project is based on [the curl version of WifiLoginer](https://github.com/ShanghaitechGeekPie/WifiLoginer/blob/master/Shell/wget-shtech.sh).

## Install

Use the following command to install ShanghaiTech Network Logger.

```sh
sudo install.sh
```

## Configure

Configure by editing `/etc/network-logger/example.toml`. You can rename the file at will. Fill in your account and email information.

You will need a working email server such as Postfix to send the network status. We recommend you send emails using an external SMTP server like QQ, NetEase, etc. You might want to read the following web pages.

- [Configure Postfix to Send Email Using External SMTP Servers](https://www.linode.com/docs/guides/postfix-smtp-debian7/)
- [什么是授权码，它又是如何设置？](https://service.mail.qq.com/cgi-bin/help?subtype=1&id=28&no=1001256)

## Enable Service

Use the following commands to enable ShanghaiTech Network Logger. Replace the example with your configuration file name.

```sh
sudo systemctl enable network-logger@example
sudo systemctl start network-logger@example
```

## Uninstall

Use the following command to uninstall ShanghaiTech Network Logger. You need to stop your service manually.

```sh
sudo uninstall.sh
```
