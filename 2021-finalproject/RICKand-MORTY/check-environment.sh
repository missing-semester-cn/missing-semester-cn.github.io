#!/bin/bash
#check the environment variable
echo "[Check] environment variable..."
if [ -z $ROS_MASTER_URI ];then
	echo"not exists"
else
	echo "OK!"
fi
#check ping
echo "[Check] ping address...   "
address=$(echo $ROS_MASTER_URI | awk -F '//' '{print $2}' |awk -F ':' '{print $1}')
ping -c 3 -q $address >output
checkping=$(echo $?)
if [ $checkping -eq 0 ]
then
	echo "OK!"
else
	echo "fail!"
fi
rm output

#check address validation
echo "[Check] address validation..."
area=$(echo $ROS_MASTER_URI | awk -F '//' '{print $2}' |awk -F ':' '{print $1}' |awk -F '.' '{print NF}')
if [ $area -eq 4 ];
then
	echo "OK!"
else 
	echo "Fail!"
fi
exit 0



