#!/bin/bash
#hand out public key stripts
#author:xingyu

#create public key

#hand out private key
ips=`echo 172.16.1.{7,8,5,51,41,31}`

for ip in $ips
do
	sshpass -p1 ssh-copy-id -i .ssh/id_rsa.pub $ip -ostricthostkeychecking=no &>/dev/null 	

done
#check private key whethe it is successful send

for ip in $ips # 循环嵌套判断
do
	ssh $ip hostname #进行循环验证
 
		if [ $? -eq  0 ];then #判断反馈结构 eq 等于的意思 成功为1 失败为0
			echo -e "\e[1;32mSuccessful \e[0m" # 执行成功，就输出successfule \e为颜色设置
		else
			echo -e "\e[1;31mError $ip \e[0m\n" # 执行失败，就输出error
		fi 
done

# 目前错误，循环命令ssh $ip hostname只执行一次，后续无主机名，但是判断成功执行。2023/5/31
	# echo -e "\e[1;32mSuccessful \e]" # 执行成功，就输出successfule \e为颜色设置
	# echo -e "\e[1;31mError $ip \e]\n" # 执行失败，就输出error
# 2023/5/31 问题已解决，原因是颜色格式错误

