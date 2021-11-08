#!/bin/bash

# test whether the environment is valiable
export ROS_MASTER_URI=http://192.168.0.100:11311
environment_variable ()
{
	echo -n "[Check] environment variable... "
	if test -z "${ROS_MASTER_URI}" 
	then
		echo "Error"
		echo "The environment variable of ROS_MASTER_URI is empty"
		echo "Done"
		exit
	else
		echo "Pass"
	fi
}

environment_variable 

# check the http address is available or not
address_validation ()
{
	echo -n "[Check] address validation...   "
	echo $ROS_MASTER_URI | awk '/http:\/\/((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:((6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])|[0-5]?\d{0,4})/'
	if [[ $? = 0 ]]
	then
		echo "Pass"
	else
		echo "Error"
		echo "This http address is invalid"
		echo "Done"
		exit
	fi
}

address_validation

# test the connection of ip included in ROS_MASTER_URI
ping_address ()
{
	echo -n "[Check] ping address...         "
	ip=$(echo $ROS_MASTER_URI | sed -E "s/http:\/\///" | sed -E "s/:.*//")
	ping -c 3 -w 5 ${ip} > /dev/null
	if [[ $? != 0 ]]
	then
		echo "Error"
		echo "This IP address can't be connected"
		echo "Done"
		exit
	else
		echo "Pass"
	fi
}

ping_address

# judge if the local ip is in the same subnet with target ip
same_subnet ()
{
	echo -n "[Check] same subset...          "
	mask=$(ifconfig | grep "netmask" | grep "broadcast" | sed -E s/.*netmask// | awk '{print $1}' | tail -1)
	ip=$(echo $ROS_MASTER_URI | sed -E "s/http:\/\///" | sed -E "s/:.*//")
	localip=$(ip a | grep inet | grep -v inet6 | awk -F 'inet ' '{print $2}' | awk -F '/' '{print $1}' | tail -1)
	a=$(echo ${mask} | awk -F '{print $1}')
	b=$(echo ${mask} | awk -F '{print $2}')
	c=$(echo ${mask} | awk -F '{print $3}')
	d=$(echo ${mask} | awk -F '{print $4}')
	let int_mask=a*256*256*256+b*256*256+c*256+d
	e=$(echo ${ip} | awk -F '{print $1}')
	f=$(echo ${ip} | awk -F '{print $2}')
	g=$(echo ${ip} | awk -F '{print $3}')
	h=$(echo ${ip} | awk -F '{print $4}')
	let int_ip=e*256*256*256+f*256*256+g*256+h
	i=$(echo ${localip} | awk -F '{print $1}')
	j=$(echo ${localip} | awk -F '{print $2}')
	k=$(echo ${localip} | awk -F '{print $3}')
	l=$(echo ${localip} | awk -F '{print $4}')
	let int_localip=i*256*256*256+j*256*256+k*256+l
	if [[ $((${int_mask}+${int_ip})) -eq $((${int_mask}+${int_localip})) ]]
	then
		echo "Pass"
	else
		echo "Error"
		echo "This IP address and local IP address are not in the same subnet"
		echo "Done"
		exit
	fi
}

same_subnet

echo "All Check Passed"
