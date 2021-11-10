#!/bin/bash
export ROS_MASTER_URI=http://192.168.0.100:11311
#检查 ROS_MASTER_URI 环境变量是否为空（为避免理解错误，此处的环境变量是通过后面的命令设置的 export ROS_MASTER_URI=http://192.168.0.100:11311）
environment_variable ()
{
	echo -n "[Check] environment variable... "
	if test -z "${ROS_MASTER_URI}" 
	then
		echo "Error:The environment variable of ROS_MASTER_URI is empty"
		exit
	else
		echo "Pass"
	fi
}
environment_variable 
#检查该环境变量是否是有效的 http 地址，在本题中约定有效的 http 地址指符合 http://[IP]:[Port] 格式，例如 http://192.168.0.100:11311
address_validation ()
{
	echo -n "[Check] address validation...   "
	echo $ROS_MASTER_URI | awk '/http:\/\/((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:((6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])|[0-5]?\d{0,4})/'
	if [[ $? = 0 ]]
	then
		echo "Pass"
	else
		echo "Error:This http address is invalid"
		exit
	fi
}
address_validation
#使用 ping 命令检查该环境变量包含的 IP 地址是否可连通
ping_address ()
{
	echo -n "[Check] ping address...         "
	ip=$(echo $ROS_MASTER_URI | sed -E "s/http:\/\///" | sed -E "s/:.*//")
	ping -c 3 -w 5 ${ip} > /dev/null
	if [[ $? != 0 ]]
	then
		echo "Error:This IP address can't be connected"
		exit
	else
		echo "Pass"
	fi
}
ping_address

echo "All Check Passed"
