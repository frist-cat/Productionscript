# asn_Rsync自动部署流程

```sh
# 在backup安装/更新rsync
ansible backup -m yum -a "name=rsync state=installed"
# 在管理机编写rsync配置文件
# 将文件分发到backup服务器
ansible backup -m copy -a "src=/etc/rsyncd.conf dest=/etc/ backup=yes"
# backup端创建虚拟用户
ansible backup -m user -a "name=rsync uid=2000 shell=/sbin/nologin create_home=no state=present"
# backup创建密码文件
ansible nfs -m lineinfile -a "path=/etc/rsync.client line=rsync_backup:2 create=true mode=600"
# 创建共享目录
ansible backup -m file -a "path=/data/ owner=rsync group=rsync state=directory"
# backup端启动rsync服务
ansible backup -m systemd -a "name=rsyncd state=started enabled=yes"
# 客户端nfs服务器配置
# nfs创建密码文件
ansible nfs -m lineinfile -a "path=/etc/rsync.client line=2 create=true mode=600"
# nfs将hosts文件传输到bak端的tmp目录下完成测试
ansible nfs -m shell -a "rsync -av /etc/hosts rsync_backup@backup::data --password-file=/etc/rsync.client"
```

