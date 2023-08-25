#!/bin/bash
#系统巡检脚本
#时间：2023/3/28

#global variables
script_outpot_file=$(cd $(dirname $0);pwd)/script_outpot

#基本判断模块
function whether_module() {
    if [ $? -ne 0 ]; then
        echo $1 >> $script_outpot_file
    else
        echo $2 >> $script_outpot_file
    fi
}


#系统基本信息模块
function basic_info() {
    echo "##############################" > ${script_outpot_file}
    echo "主机名：$(hostname)" >> ${script_outpot_file}
    echo "私网网卡IP：$(hostname -I )" >> ${script_outpot_file}
    echo "公网IP：$(curl -s ipconfig.io)" >> ${script_outpot_file}
    echo "系统发行版本：$(cat /etc/os-release | grep PRETTY_NAME)" >> ${script_outpot_file}
    echo "内核版本：$(uname -r)" >> ${script_outpot_file}
    echo "系统字符集：$LANG" >> ${script_outpot_file}
    echo -e "##############################" >> ${script_outpot_file}
}

#CPU信息模块
function cpu_info() {
    echo "CPU架构：$(uname -m)" >> ${script_outpot_file}
    echo "CPU型号：$(lscpu | grep "Model name" | awk -F: '{print $2}' | column -t)" >> ${script_outpot_file}
    echo "CPU颗数：$(lscpu | grep "Socket" | awk -F: '{print $2}')" >> ${script_outpot_file}
    echo "CPU核数：$(lscpu | grep "^CPU(s)" | awk -F: '{print $2}' | column -t)" >> $script_outpot_file
    echo "CPU空闲率：$(mpstat | awk 'NR==4{print $NF"%"}')" >> $script_outpot_file
    echo "CPU用户使用率：$(mpstat | awk 'NR==4{print $4"%"}')" >> $script_outpot_file
    echo "CPU系统使用率：$(mpstat | awk 'NR==4{print $6"%"}')" >> $script_outpot_file
    echo "CPU的IO占用率：$(mpstat | awk 'NR==4{print $7"%"}')" >> $script_outpot_file
    echo -e "#################################" >> $script_outpot_file
}


#内存信息模块
function memory_info() {
    echo "内存总使用率：$(free -h | awk 'NR==2{print $2}')" >> $script_outpot_file
    echo "可用内存：$(free -h | awk 'NR==2{print $4}')" >> $script_outpot_file
    echo "已用内存：$(free -h | awk 'NR==2{print $3}')" >> $script_outpot_file
    num=$(free | awk 'NR==3{print $3}')
    if [ $num -ne 0 ]; then

        echo "SWAP总容量：$(free -h | awk 'NR==3{print $2}')" >> $script_outpot_file
        echo "SWAP可用内存：$(free -h | awk 'NR==3{print $4}')" >> $script_outpot_file
        echo "SWAP已用内存：$(free -h | awk 'NR==3{print $3}')" >> $script_outpot_file
    fi
    echo -e "#################################" >> $script_outpot_file
}

#磁盘信息模块
function disk_info() {
    disk=($(ls /dev/ | grep -E -w "vd[a-z]+"))
    echo "系统磁盘数：${#disk[@]}" >> $script_outpot_file
    echo -e "系统各磁盘大小：" >> $script_outpot_file
    for i in ${disk[@]}; 
    do
        size=$(fdisk -l /dev/${i} | awk -F"[:,]" 'NR==2{print $2}' | column -t)
        echo -e "${i}\t${size}" >> $script_outpot_file
    done

    partition_size=$(df -h | grep -v "Filesystem" | awk '{print $1,$2}')
    echo -e "系统分区大小：" >> $script_outpot_file
    for i in ${partition_size[@]}; 
    do
        echo -e "${i}" >> $script_outpot_file
    done

    partition_used=$(df -h | grep -v "Filesystem" | awk '{print $1,$3}')
    echo -e "系统分区使用率：" >> $script_outpot_file
    for i in ${partition_used[@]};  
    do
        echo -e "${i}" >> $script_outpot_file
    done

    partition_id=$(fdisk -l | grep "^/dev" | awk '{print $1,$6}' | awk -F/ '{print $3}')
    echo -e "系统分区inode已使用使用：" >> $script_outpot_file
    for i in ${partition_id[@]};  
    do
        echo -e "${i}" >> $script_outpot_file
    done

    echo -e "#################################" >> $script_outpot_file
}

#负载
function load_info() {

    echo "最近一分钟负载：$(top -bn1 | head -1 | awk -F"[:,]" '{print $8}')" >> $script_outpot_file
    echo "最近五分钟负载：$(top -bn5 | head -1 | awk -F"[:,]" '{print $9}')" >> $script_outpot_file
    echo "最近十五分钟负载：$(top -bn10 | head -1 | awk -F"[:,]" '{print $10}')" >> $script_outpot_file
    echo "################################" >> $script_outpot_file

}


#用户信息模块
function user_info() {

    echo "可登录的用户数：$(grep "/bin/bash" /etc/passwd | wc -l)" >> $script_outpot_file
    echo "可登录用户：$(grep "/bin/bash" /etc/passwd | awk -F: '{print $1}')" >> $script_outpot_file
    echo "虚拟用户数量：$(grep "/sbin/nologin" /etc/passwd | wc -l)" >> $script_outpot_file
    echo -e "#################################" >> $script_outpot_file
}

#dns信息模块
function dns_info() {

    echo "DNS服务器：$(grep "nameserver"  /etc/resolv.conf | awk '{print $2}')" >> $script_outpot_file
    dns_ip=($(grep "nameserver"  /etc/resolv.conf | awk '{print $2}'))
    for n in ${dns_ip[@]}
    do
        ping -c3 $n  &>>/dev/null
        if [ $? -eq 0 ]; then
            echo "dns服务器连接通畅" >> $script_outpot_file
        else
            echo "dns服务器连接错误" >> $script_outpot_file
        fi
    done
    echo -e "#################################" >> $script_outpot_file
}

#判断selinux是否开启
function selinux_status() {

    [[ $i -eq "Disabled" || $i -eq "Premissive" ]] && echo "Selinux状态为：关闭" >> $script_outpot_file || echo "Selinux状态为：开启" >> $script_outpot_file
    echo -e "#################################" >> $script_outpot_file
}

#防火墙状态
function firewall_status() {

    firewall_status="$(systemctl is-active firewalld)"
    if [[ $firewall_status -eq "unknown" || $firewall_status -eq "inactive" ]]; then
        echo "防火墙状态为：关闭" >> $script_outpot_file
    else
        echo "防火墙状态为：开启" >> $script_outpot_file
        iptables=$(iptables -nL)
        echo -e "防火墙策略为：\n${iptables}" >> $script_outpot_file
    fi
    echo -e "#################################" >> $script_outpot_file
}

#显示已经开启的端口
function port_status() {
    port_status="$(ss -lntup | awk 'NR>1{print $5}' | sed 's#.*:##g' | sort -n | uniq)"
    echo -e "已经开启的端口：\n${port_status}" >> $script_outpot_file
    echo -e "#################################" >> $script_outpot_file
}

#显示进程状态
function process_status() {
    zombie_process=$(ps -aux | grep -w T | wc -l)
    stopped_process=$(ps -aux | grep -w T | wc -l)
    sleeping_process=$(ps -aux | grep -w S | wc -l)
    echo "系统僵尸进程数量：$zombie_process" >> $script_outpot_file
    echo "系统挂起进程数量：$stopped_process" >> $script_outpot_file
    echo "系统睡眠进程数量：$sleeping_process" >> $script_outpot_file
    echo -e "#################################" >> $script_outpot_file
}

#查看定时任务内容
function crontab_info() {
    crontab_info=$(crontab -l &>/dev/null)
    whether_module "系统无定时任务" "系统定时任务如下：\n$crontab_info"
    echo -e "#################################" >> $script_outpot_file
}
main() {
    basic_info
    echo -e "10% \e[1;32mbasic_info successful!\e[0m"
    cpu_info
    echo -e "20% \e[1;32mcpu_info successful\e[0m"
    memory_info
    echo -e "30% \e[1;32mmemory_info successful\e[0m"
    disk_info
    echo -e "40% \e[1;32mdisk_info successful\e[0m"
    load_info
    echo -e "50% \e[1;32mload_info successful\e[0m"
    user_info
    echo -e "60% \e[1;32muser_info successful\e[0m"
    dns_info
    echo -e "70% \e[1;32mdns_info successful\e[0m"
    selinux_status
    echo -e "80% \e[1;32mselinux_status successful\e[0m"
    firewall_status
    echo -e "83% \e[1;32mfirewall_status successful\e[0m"
    port_status
    echo -e "90% \e[1;32mport_status successful\e[0m"
    process_status
    echo -e "95% \e[1;32mprocess_status successful\e[0m"
    crontab_info
    echo -e "100% \e[1;32mcrontab_info successful\e[0m"

}
main
