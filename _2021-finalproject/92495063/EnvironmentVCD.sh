#!bin/bash

#检查ROS_MASTER_URI是否存在
echo "[Check] environment variable"
if [ $ROS_MASTER_URI ]; then
	echo " ~Pass"
       	W=1
else
      	echo " Error"
	W=0
fi

#检查地址是否有效
echo "[Check] address variable"
if [ "$ROS_MASTER_URI"="http://*:*" ]; then
	echo " ~Pass"
	B=1
else
	echo " Error"
	B=0
fi

#检查连通性
	IP=$ROS_MASTER_URI
	IP=${IP:7}
	IP=${IP%:*}
echo "[Check] ping address"
echo "Checking ip : $IP" 

if [ `ping $IP -c 2 | grep 'rtt' | cut -c1-3` ]; then
	echo " ~Pass"
	C=1
       
else
	echo " Error"
	C=0
fi

#检查环境变量的IP是否与计算机处于同一子网
echo "[Check] same subnet"
strng=`ifconfig | grep -A 1 "wlp1s0" | grep "inet"`
wIP=${strng:13:14} wIP=${wIP// /} 
Mask=${strng#*netmask} Mask=${Mask// /} Mask=${Mask%broad*} 

#echo "$IP $wIP $Mask"

 a=`echo "$IP"|awk -F. '{for(i=1;i<=NF;i++){a="";b=$i;while(b){a=b%2 a;b=int(b/2)}printf("%08d%s",a,i!=NF?".":"\n")}}'`
 b=`echo "$wIP"|awk -F. '{for(i=1;i<=NF;i++){a="";b=$i;while(b){a=b%2 a;b=int(b/2)}printf("%08d%s",a,i!=NF?".":"\n")}}'`
 c=`echo "$Mask"|awk -F. '{for(i=1;i<=NF;i++){a="";b=$i;while(b){a=b%2 a;b=int(b/2)}printf("%08d%s",a,i!=NF?".":"\n")}}'`

a1=`echo ${a//./}`
b1=`echo ${b//./}`
c1=`echo ${c//./}`

A=`echo "$(($a1 & $c1))"`
B=`echo "$(($b1 & $c1))"`
#echo -e "$A\n$B"

if [ $A -eq $B ]; then 
	echo " ~Pass"
	D=1
else
	echo " Different"
	D=0
fi

#结束
if [[ $W -eq 1 && $B -eq 1 && $C -eq 1 && $D -eq 1 ]]; then
echo "All Check Passed"
else
echo "Something wrong:"
	if [ $W -eq 0 ]; then echo "#environment"
	fi
	if [ $B -eq 0 ]; then echo "#address"    
	fi
	if [ $C -eq 0 ]; then echo "#ping"
	fi
	if [ $D -eq 0 ]; then echo "#subnet"
	fi
fi

#test
