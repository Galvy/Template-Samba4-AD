# Template-Samba4-AD
This is my personale Samba4 AD Template for Zabbix 5

# Introduction
Until today 26/6/2021 there is no a decent Zabbix Template(my own opinion) for monitoring Samba4 AD so i still using Nagios just for this..until today.
Enjoy!

# Installation
1) install jq with yum or apt install jq

sudo apt-get install jq

2) copy samba4_ad.conf in your zabbix-agent etc folder

Es: /etc/zabbix/zabbix_agentd.d/samba4_ad.conf

3) add zabbix user to sudo with a tool visudo

4) allows 'zabbix' user to run all commands without password.
zabbix ALL=NOPASSWD: ALL

5) Allow active-check in your zabbix_agentd.conf and AllowKey=system.run[*]

6) copy samba4_ad.sh in /usr/local/bin

7) add cron tasks like:

*/15 * * * * /usr/local/bin/samba4_ad.sh doJson > /dev/null 2>&1

0 */2 * * * /usr/local/bin/samba4_ad.sh doDbCheck > /dev/null 2>&1
