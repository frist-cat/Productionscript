#!/bin/bash

# 随机生成IP地址
generate_random_ip() {
    ip=""
    for i in {1..4}; do
        ip+=.$(( RANDOM % 256 ))
    done
    echo "${ip:1}"
}

# 随机生成状态码
generate_random_status_code() {
    status_num=("200" "201" "304" "404" "401" "502")
    echo ${status_num[$(( RANDOM % ${#status_num[@]} ))]}
}

# 随机生成大于10k的字节数
generate_random_bytes() {
    echo $(( RANDOM % 9000 + 10000 ))
}

# 随机生成浏览器版本
generate_random_browser_version() {
    versions=("Chrome" "Firefox" "Safari" "Edge")
    echo "${versions[$(( RANDOM % ${#versions[@]} ))]}"
}

# 生成随机访问时间
generate_random_access_time() {
    start_timestamp=$(date -d "2020-01-01" +"%s")  
    # 定义起始时间戳为2020年1月1日
    end_timestamp=$(date -d "now" +"%s") 
    # 获取当前时间戳
    timestamp=$(( RANDOM % (end_timestamp - start_timestamp) + start_timestamp ))
    # 从开始时间戳到截止时间搓的一个随机
    access_time=$(date -d "@${timestamp}" "+%d/%b/%Y-%H:%M:%S %z")
    # 生成标准access标准格式
    echo "${access_time}"
}

generate_access_log() {
    ip=$(generate_random_ip)
    status_code=$(generate_random_status_code)
    bytes=$(generate_random_bytes)
    browser_version=$(generate_random_browser_version)
    access_time=$(generate_random_access_time)

    echo "${ip} - - [${access_time}] \"GET /sdk HTTP/1.1\" ${status_code} ${bytes} \"-\" \"Mozilla/5.0 (${browser_version})\" \"-\""
}


# 定义输出文件位置
access=$(cd $(dirname $0);pwd)
# 主函数 生成指定数量的访问日志
main() {
#generate_random_ip
#generate_random_status_code
#generate_random_bytes
#generate_random_access_time

    i=0
    echo "start" > $access/access.log
    while [[ $i -le 2000000 ]]
    do 
        generate_access_log >> $access/access.log
	let i++
    done

}
main

