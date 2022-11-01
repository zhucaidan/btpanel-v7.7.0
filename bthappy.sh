#!/bin/bash
LANG=en_US.UTF-8

echo "
+----------------------------------------------------------------------
| Bt-WebPanel-Happy FOR CentOS
+----------------------------------------------------------------------
| 本脚本用于宝塔面板7.7版本的一键开心，因为脚本造成的问题请自行负责！
+----------------------------------------------------------------------
| 安装脚本：curl -sSO https://cdn.jsdelivr.net/gh/ztkink/bthappy@latest/install_panel.sh && bash install_panel.sh
+----------------------------------------------------------------------
"
while [ "$go" != 'y' ] && [ "$go" != 'n' ]
do
	read -p "请确认你已经安装的版本是7.7，请确认你将开心的宝塔面板用于学习！(y/n): " go;
done

if [ "$go" == 'n' ];then
	exit;
fi

#修改强制登录开始
sed -i "s|if (bind_user == 'True') {|if (bind_user == 'REMOVED') {|g" /www/server/panel/BTPanel/static/js/index.js
rm -rf /www/server/panel/data/bind.pl
#修改强制登录结束
echo -e "修改强制登陆中..."
sleep 2
echo -e "修改强制登陆结束."
sleep 2
echo -e "插件商城开心开始..."
#判断plugin.json文件是否存在,存在删除之后再下载,不存在直接下载
plugin_file="/www/server/panel/data/plugin.json"
if [ -f ${plugin_file} ];then
    chattr -i /www/server/panel/data/plugin.json
    rm /www/server/panel/data/plugin.json
    cd /www/server/panel/data
    wget https://cdn.jsdelivr.net/gh/ztkink/bthappy@latest/plugin.json
    chattr +i /www/server/panel/data/plugin.json
else
    cd /www/server/panel/data
    wget https://cdn.jsdelivr.net/gh/ztkink/bthappy@latest/plugin.json
    chattr +i /www/server/panel/data/plugin.json
fi
echo -e "插件商城开心结束."
sleep 3
echo -e "文件防修改开始..."
#判断repair.json文件是否存在,存在删除之后再下载,不存在直接下载
repair_file="/www/server/panel/data/repair.json"
if [ -f ${repair_file} ];then
    chattr -i /www/server/panel/data/repair.json
    rm /www/server/panel/data/repair.json
    cd /www/server/panel/data
    wget https://cdn.jsdelivr.net/gh/ztkink/bthappy@latest/repair.json
    chattr +i /www/server/panel/data/repair.json
else
    cd /www/server/panel/data
    wget https://cdn.jsdelivr.net/gh/ztkink/bthappy@latest/repair.json
    chattr +i /www/server/panel/data/repair.json
fi
echo -e "文件防修改结束."
sleep 3
     /etc/init.d/bt restart 	
sleep 3
    bt default
sleep 2 
echo -e "宝塔面板开心结束！"
