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






# ################# 也可用 git diff 来比较两次提交之间被 Git 跟踪的文件的差异，查看是否有 package.json 文件。#################
# # jenkins 中有两个环境变量 "GIT_PREVIOUS_SUCCESSFUL_COMMIT(上次在此分支上成功构建提交的哈希)" 和 "GIT_COMMIT" ，在第一次构建时，GIT_PREVIOUS_SUCCESSFUL_COMMIT 为空
# #!/bin/bash
# set -euo pipefail  # 严格模式：出错即停

# # if git diff --name-only HEAD~1 HEAD | grep -q 'package.json'; then
# #   echo "package.json has changed"
# # else
# #   echo "package.json has not changed"
# # fi
# # # git diff --name-only HEAD~1 HEAD 这部分会列出所有在当前提交和前一次提交之间发生变化的文件名称
# # # | 是管道符号，它会把前一个命令的输出作为后一个命令的输入。
# # # grep -q 'package.json' 会查找前一个命令输出中是否包含字符串 package.json，-q 参数意味着它会在静默模式下运行，即成功时不输出任何东西。
# # # 命令行可直接运行：
# # # git diff --name-only HEAD~1 HEAD | grep -q 'package.json' && echo "package.json has been modified." || echo "package.json has not been modified."


# # 获取当前 commit 和上一次成功构建的 commit
# CURRENT_COMMIT="${GIT_COMMIT:-$(git rev-parse HEAD)}" # GIT_COMMIT若是为空，就用 git rev-parse HEAD 获取
# PREV_COMMIT="${GIT_PREVIOUS_SUCCESSFUL_COMMIT:-}"

# # 如果是首次构建（无上一次成功 commit），则视为需要安装
# if [ -z "$PREV_COMMIT" ]; then
#   echo "没有找到以前成功的构建。但 package.json 可能有更新。"
#   echo "Running npm install..."
#   npm install # npm ci
#   exit 0
# fi

# # 检查两个 commit 之间是否有 package.json 的变更（仅根目录）
# # 使用 --diff-filter=d 排除被删除的文件（如果你关心“存在且变化”，可保留）
# if git diff --name-only --diff-filter=ACMRT "$PREV_COMMIT" "$CURRENT_COMMIT" | grep -q "^package\.json$"; then
#   echo "Detected changes in package.json between $PREV_COMMIT and $CURRENT_COMMIT"
#   echo "Running npm install..."
#   npm install
# fi


