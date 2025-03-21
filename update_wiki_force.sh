#!/bin/bash

# 定义日志文件和部署目录的变量
WIKI_HOME="/home/yangshengyuan/code/quartz"  # 替换为 WIKI_HOME 的实际路径
WIKI_DEPLOY="/home/yangshengyuan/soft/nginx-ldap/public"  # 替换为 WIKI_DEPLOY 的实际路径
LOG_FILE="$WIKI_HOME/task.log"

# 进入 WIKI_HOME 目录
cd "$WIKI_HOME"

# 检查目录是否正确
if [ $? -ne 0 ]; then
    echo "错误：无法进入目录 $WIKI_HOME" | tee -a "$LOG_FILE"
    exit 1
fi

# 执行 git 强制更新以及子模块更新
git pull -f && cd content && git checkout main -f && git pull -f && cd -


echo "Git 更新成功，正在清理 public 目录..."
rm -rf public/*

# 检查删除操作是否成功
if [ $? -ne 0 ]; then
    echo "错误：删除 public 目录下文件失败。" | tee -a "$LOG_FILE"
    exit 1
fi

# 执行构建操作
npx quartz build

# 检查构建操作是否成功
if [ $? -ne 0 ]; then
    echo "错误：执行 npx quartz build 失败。" | tee -a "$LOG_FILE"
    exit 1
fi

# 拷贝 public 目录下的所有内容到 WIKI_DEPLOY 目录中
echo "构建成功，正在部署..."
#cp -rf public/. "$WIKI_DEPLOY"
rsync -a --delete public/  "$WIKI_DEPLOY"
# 检查拷贝操作是否成功
if [ $? -ne 0 ]; then
    echo "错误：拷贝文件到 $WIKI_DEPLOY 失败。" | tee -a "$LOG_FILE"
    exit 1
fi

# 写入更新成功日志
echo "$(date +"%Y-%m-%d %H:%M:%S") - 更新成功" | tee -a "$LOG_FILE"

exit 0
