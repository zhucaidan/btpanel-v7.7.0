# btpanel-v7.7.0
btpanel-v7.7.0-backup  官方原版v7.7.0版本面板备份

**Centos/Ubuntu/Debian安装命令 独立运行环境（py3.7）**

```Bash
curl -sSO https://raw.githubusercontent.com/kxjhcmc/btpanel-v7.7.0/main/install/install_panel.sh && bash install_panel.sh
```
建议配合优化脚本使用：


这个是根据个人使用习惯做的宝塔面板一键优化补丁，主要有以下优化项目：
1.去除宝塔面板强制绑定账号
2.去除各种删除操作时的计算题与延时等待
3.去除创建网站自动创建的垃圾文件（index.html、404.html、.htaccess）
4.关闭未绑定域名提示页面，防止有人访问未绑定域名直接看出来是用的宝塔面板
5.关闭活动推荐与在线客服

wget -O optimize.sh http://f.cccyun.cc/bt/optimize.sh && bash optimize.sh
