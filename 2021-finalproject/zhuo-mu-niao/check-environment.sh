#!/usr/bin/bash
echo "test"
echo "[Check] environment variable..."
if [ -z $ROS_MASTER_URI ];
then
	echo"Failed"
else
	echo "Pass"
fi

echo "[Check] ping address..."
uri=$(echo $ROS_MASTERUR_URI | awk '/http:\d+\.\d+\.\d+\.\d+\:')
if [ -z $uri ];
then
	echo "Pass"
else
	echo "Error"
fi
