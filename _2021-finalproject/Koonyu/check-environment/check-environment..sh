#!/bin/bash
#check environment variable
if [ $ROS_MASTER_URI ];then
	echo "[Check] environment variable... Pass"
        A=0
else
	echo "[Check] environment variable... Failed"
        A=1
fi

#check address validation " http://[[1-255].[0-255].[0-255].[1-255]]:[PORT] "
#s/REGEX/SUBSTITUTION/
#awk is used to analyze url which is valid or not
if (export | grep ROS_MASTER_URI | sed -E "s/.*=//" | sed -E "s/\"//" | sed -E "s/\"//" | sed -E "s/http:\/\///" | sed -E "s/:.*//" | awk -F. '{if(NF==4 && $1>0 && $1<=255 && $2>=0 && $2<=255 && $3>=0 && $3<=255 && $4>0 && $4<255) exit 0; else exit 1}');then #check if this IP contents this model " [[1-255].[0-255].[0-255].[1-255]] "
        HTTP=$(export | grep ROS_MASTER_URI | sed -E "s/.*=//" | sed -E "s/\"//" | sed -E "s/\"//")
        judge=$(echo $HTTP | awk '/^http:\/\/.:*[0-9]+/{print $0}')
        if [[ $judge ]];then
		 echo "[Check] address validation...   Pass"
                 B=0
        fi
else
	echo "[Check] address validation...   Failed"
        B=1
fi

#check pinging address which is valid or not
IP=$(export | grep ROS_MASTER_URI | sed -E "s/.*=//" | sed -E "s/\"//" | sed -E "s/\"//" | sed -E "s/http:\/\///" | sed -E "s/:.*//")
ping -c 1 $IP
if [[ $? -eq 0 ]];then     
        echo "[Check] ping address...         Pass"
        C=0
else                   
        echo "[Check] ping address...         Failed"
        C=1
fi

#check subnet 
a=$(echo "$IP" | awk -F "." '{print $1}')
b=$(echo "$IP" | awk -F "." '{print $2}')
c=$(echo "$IP" | awk -F "." '{print $3}')
d=$(echo "$IP" | awk -F "." '{print $4}')

e=$(ifconfig | awk '/netmask/{print $2}'  | awk 'NR==2' | awk -F "." '{print $1}')
f=$(ifconfig | awk '/netmask/{print $2}'  | awk 'NR==2' | awk -F "." '{print $2}')
g=$(ifconfig | awk '/netmask/{print $2}'  | awk 'NR==2' | awk -F "." '{print $3}')
h=$(ifconfig | awk '/netmask/{print $2}'  | awk 'NR==2' | awk -F "." '{print $4}')

i=$(ifconfig | awk '/netmask/{print $4}'  | awk 'NR==2' | awk -F "." '{print $1}')
j=$(ifconfig | awk '/netmask/{print $4}'  | awk 'NR==2' | awk -F "." '{print $2}')
k=$(ifconfig | awk '/netmask/{print $4}'  | awk 'NR==2' | awk -F "." '{print $3}')
l=$(ifconfig | awk '/netmask/{print $4}'  | awk 'NR==2' | awk -F "." '{print $4}')

m=$(echo "obase=2;$(($a&$i))" | bc)
n=$(echo "obase=2;$(($b&$j))" | bc)
o=$(echo "obase=2;$(($c&$k))" | bc)
p=$(echo "obase=2;$(($d&$l))" | bc)

q=$(echo "obase=2;$(($e&$i))" | bc)
r=$(echo "obase=2;$(($f&$j))" | bc)
s=$(echo "obase=2;$(($g&$k))" | bc)
t=$(echo "obase=2;$(($h&$l))" | bc)

if (($m == $q && $n == $r && $o == $s && $p == $t));then
	echo "[Check] same subnet...          Pass"
        D=0
else
	echo "[Check] same subnet...          Failed"
        D=1
fi

#Result of check
if [[ $W -eq 0 && $B -eq 0 && $C -eq 0 && $D -eq 0 ]]; then
echo "All Check Passed"
else
echo "Something wrong:"
	if [ $A -eq 1 ]; then echo "#environment"
	fi
	if [ $B -eq 1 ]; then echo "#address"    
	fi
	if [ $C -eq 1 ]; then echo "#ping"
	fi
	if [ $D -eq 1 ]; then echo "#subnet"
	fi
fi
