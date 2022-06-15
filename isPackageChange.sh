#!/bin/sh

function isPackageChange () {
	if [[ ! -f 'package.md5' ]]; then
		# 生成 md5 文件
		md5sum package.json |awk '{print $1}' > package.md5

        	# 没有 md5 文件时，检查 node_modules 文件夹是否存在，如果不存在就执行 npm install
		if [[ ! -d "node_modules" ]]; then
			npm install
		fi
    
	else
  
		# 判断 package.json 文件有无改变
		md5_old=`cat package.md5`
		md5_new=`md5sum package.json |awk '{print $1}'`
        	
		# 如果新旧文件不一样，就执行 npm install
		if [ $md5_old != $md5_new ];then
		  echo "md5_old=$md5_old,md5_new=$md5_new"
		  echo "package.json文件有更新，开始执行npm install"
		  echo "$md5_new" > package.md5
		  npm install
		fi
	fi
}

isPackageChange
