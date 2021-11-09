#!/bin/bash



#设置一些变量
param=$1    
param_ip_port=0
param_ip="Invalid ip"
param_port=1
param_len=${#param}
if [ ! $# -eq 0 ];
then
  	
  #判断是否为空 
  if test $1 = ""   
  then
	echo "[Check] environment variable... Fail"  
  else
	echo "[Check] environment variable... Pass"
  fi
  #判断前缀是否为http://
  if [ `echo ${param:0:7}` = "http://" ]; 
  then 
       #截取后面的内容
	 param_ip_port=${param:7:$param_len}          
       #cut命令分出ip和port
	 param_ip=$(echo ${param_ip_port}|cut -f1 -d ':' )
         param_port=$(echo ${param_ip_port}|cut -f2 -d ':') 
	echo "[Check] address validation...   Pass"
       #ping ip 并将所有输出丢弃（重定向到空设备文件）
       #param  -c count   -i interval   -W deadline 
       # 2>&1>file file 只被打开一次,stdout和stderr不会互相覆盖
       ping -c2 -i0.3 -W2 ${param_ip} 2>&1>/dev/null  
       if [ $? != 0 ]; then
	       echo "[Check] ping address...         Fail"
	else
	       echo "[Check] ping address...         Pass"
       fi
  else 
	echo "[Check] address validation...   Fail" 
  fi
else
	echo "Please enter a param"
fi
