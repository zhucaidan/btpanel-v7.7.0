#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8
setup_path=/www
#if [ $1 != "" ];then
	#setup_path=$1;
#fi

#检测磁盘数量
sysDisk=`cat /proc/partitions|grep -v name|grep -v ram|awk '{print $4}'|grep -v '^$'|grep -v '[0-9]$'|grep -v 'vda'|grep -v 'xvda'|grep -v 'sda'|grep -e 'vd' -e 'sd' -e 'xvd'`
if [ "${sysDisk}" == "" ]; then
	echo -e "ERROR!This server has only one hard drive,exit"
	echo -e "此服务器只有一块磁盘,无法挂载"
	echo -e "Bye-bye"
	exit;
fi
#检测/www目录是否已挂载磁盘
mountDisk=`df -h | awk '{print $6}' |grep www`
if [ "${mountDisk}" != "" ]; then
	echo -e "www directory has been mounted,exit"
	echo -e "www目录已被挂载,不执行任何操作"
	echo -e "Bye-bye"
	exit;
fi
#检测是否有windows分区
winDisk=`fdisk -l |grep "NTFS\|FAT32"`
if [ "${winDisk}" != "" ];then
	echo 'Warning: The Windows partition was detected. For your data security, Mount manually.';
	echo "危险 数据盘为windwos分区，为了你的数据安全，请手动挂载，本脚本不执行任何操作。"
	exit;
fi
echo "
+----------------------------------------------------------------------
| Bt-WebPanel Automatic disk partitioning tool
+----------------------------------------------------------------------
| Copyright © 2015-2017 BT-SOFT(http://www.bt.cn) All rights reserved.
+----------------------------------------------------------------------
| Auto mount partition disk to $setup_path
+----------------------------------------------------------------------
"


#数据盘自动分区
fdiskP(){
	
	for i in `cat /proc/partitions|grep -v name|grep -v ram|awk '{print $4}'|grep -v '^$'|grep -v '[0-9]$'|grep -v 'vda'|grep -v 'xvda'|grep -v 'sda'|grep -e 'vd' -e 'sd' -e 'xvd'`;
	do
		#判断指定目录是否被挂载
		isR=`df -P|grep $setup_path`
		if [ "$isR" != "" ];then
			echo "Error: The $setup_path directory has been mounted."
			return;
		fi
		
		isM=`df -P|grep '/dev/${i}1'`
		if [ "$isM" != "" ];then
			echo "/dev/${i}1 has been mounted."
			continue;
		fi
			
		#判断是否存在未分区磁盘
		isP=`fdisk -l /dev/$i |grep -v 'bytes'|grep "$i[1-9]*"`
		if [ "$isP" = "" ];then
				#开始分区
				fdisk -S 56 /dev/$i << EOF
n
p
1


wq
EOF

			sleep 5
			#检查是否分区成功
			checkP=`fdisk -l /dev/$i|grep "/dev/${i}1"`
			if [ "$checkP" != "" ];then
				#格式化分区
				mkfs.ext4 /dev/${i}1
				mkdir $setup_path
				#挂载分区
				sed -i "/\/dev\/${i}1/d" /etc/fstab
				echo "/dev/${i}1    $setup_path    ext4    defaults    0 0" >> /etc/fstab
				mount -a
				df -h
			fi
		else
			#判断是否存在Windows磁盘分区
			isN=`fdisk -l /dev/$i|grep -v 'bytes'|grep -v "NTFS"|grep -v "FAT32"`
			if [ "$isN" = "" ];then
				echo 'Warning: The Windows partition was detected. For your data security, Mount manually.';
				return;
			fi
			
			#挂载已有分区
			checkR=`df -P|grep "/dev/$i"`
			if [ "$checkR" = "" ];then
					mkdir $setup_path
					sed -i "/\/dev\/${i}1/d" /etc/fstab
					echo "/dev/${i}1    $setup_path    ext4    defaults    0 0" >> /etc/fstab
					mount -a
					df -h
			fi
			
			#清理不可写分区
			echo 'True' > $setup_path/checkD.pl
			if [ ! -f $setup_path/checkD.pl ];then
					sed -i "/\/dev\/${i}1/d" /etc/fstab
					mount -a
					df -h
			else
					rm -f $setup_path/checkD.pl
			fi
		fi
	done
}
stop_service(){

	/etc/init.d/bt stop

	if [ -f "/etc/init.d/nginx" ]; then
		/etc/init.d/nginx stop > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/httpd" ]; then
		/etc/init.d/httpd stop > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/mysqld" ]; then
		/etc/init.d/mysqld stop > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/pure-ftpd" ]; then
		/etc/init.d/pure-ftpd stop > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/tomcat" ]; then
		/etc/init.d/tomcat stop > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/redis" ]; then
		/etc/init.d/redis stop > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/memcached" ]; then
		/etc/init.d/memcached stop > /dev/null 2>&1
	fi

	if [ -f "/www/server/panel/data/502Task.pl" ]; then
		rm -f /www/server/panel/data/502Task.pl
		if [ -f "/etc/init.d/php-fpm-52" ]; then
			/etc/init.d/php-fpm-52 stop > /dev/null 2>&1
		fi

		if [ -f "/etc/init.d/php-fpm-53" ]; then
			/etc/init.d/php-fpm-53 stop > /dev/null 2>&1
		fi

		if [ -f "/etc/init.d/php-fpm-54" ]; then
			/etc/init.d/php-fpm-54 stop > /dev/null 2>&1
		fi

		if [ -f "/etc/init.d/php-fpm-55" ]; then
			/etc/init.d/php-fpm-55 stop > /dev/null 2>&1
		fi

		if [ -f "/etc/init.d/php-fpm-56" ]; then
			/etc/init.d/php-fpm-56 stop > /dev/null 2>&1
		fi

		if [ -f "/etc/init.d/php-fpm-70" ]; then
			/etc/init.d/php-fpm-70 stop > /dev/null 2>&1
		fi

		if [ -f "/etc/init.d/php-fpm-71" ]; then
			/etc/init.d/php-fpm-71 stop > /dev/null 2>&1
		fi
	fi
}

start_service()
{
	/etc/init.d/bt start

	if [ -f "/etc/init.d/nginx" ]; then
		/etc/init.d/nginx start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/httpd" ]; then
		/etc/init.d/httpd start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/mysqld" ]; then
		/etc/init.d/mysqld start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/pure-ftpd" ]; then
		/etc/init.d/pure-ftpd start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/tomcat" ]; then
		/etc/init.d/tomcat start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/redis" ]; then
		/etc/init.d/redis start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/memcached" ]; then
		/etc/init.d/memcached start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/php-fpm-52" ]; then
		/etc/init.d/php-fpm-52 start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/php-fpm-53" ]; then
		/etc/init.d/php-fpm-53 start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/php-fpm-54" ]; then
		/etc/init.d/php-fpm-54 start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/php-fpm-55" ]; then
		/etc/init.d/php-fpm-55 start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/php-fpm-56" ]; then
		/etc/init.d/php-fpm-56 start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/php-fpm-70" ]; then
		/etc/init.d/php-fpm-70 start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/php-fpm-71" ]; then
		/etc/init.d/php-fpm-71 start > /dev/null 2>&1
	fi

	if [ -f "/etc/init.d/php-fpm-72" ]; then
		/etc/init.d/php-fpm-71 start > /dev/null 2>&1
	fi
	
	if [ -f "/etc/init.d/php-fpm-73" ]; then
		/etc/init.d/php-fpm-71 start > /dev/null 2>&1
	fi

	echo "True" > /www/server/panel/data/502Task.pl
}

while [ "$go" != 'y' ] && [ "$go" != 'n' ]
do
	read -p "Do you want to try to mount the data disk to the $setup_path directory?(y/n): " go;
done

if [ "$go" = 'n' ];then
	echo -e "Bye-bye"
	exit;
fi

if [ -f "/etc/init.d/bt" ] && [ -f "/www/server/panel/data/port.pl" ]; then
	disk=`cat /proc/partitions|grep -v name|grep -v ram|awk '{print $4}'|grep -v '^$'|grep -v '[0-9]$'|grep -v 'vda'|grep -v 'xvda'|grep -v 'sda'|grep -e 'vd' -e 'sd' -e 'xvd'`
	diskFree=`cat /proc/partitions |grep ${disk}|awk '{print $3}'`
	wwwUse=`du -sh -k /www|awk '{print $1}'`

	if [ "${diskFree}" -lt "${wwwUse}" ]; then
		echo -e "Sorry,your data disk is too small,can't coxpy to the www."
		echo -e "对不起，你的数据盘太小,无法迁移www目录数据到此数据盘"
		exit;
	else
		echo -e ""
		echo -e "stop bt-service"
		echo -e "停止宝塔服务"
		echo -e ""
		sleep 3
		stop_service
		echo -e ""
		mv /www /bt-backup
		echo -e "disk partition..."
		echo -e "磁盘分区..."
		sleep 2
		echo -e ""
		fdiskP
		echo -e ""
		echo -e "move disk..."
		echo -e "迁移数据中..."
		\cp -r -p -a /bt-backup/* /www
		echo -e ""
		echo -e "Done"
		echo -e "迁移完成"
		echo -e ""
		echo -e "start bt-service"
		echo -e "启动宝塔服务"
		echo -e ""
		start_service
	fi
else
	fdiskP
	echo -e ""
	echo -e "Done"
	echo -e "挂载成功"
fi

