#!/bin/bash
######################################################################################
# Hugo 部署脚本 on Github Pages
# 基本是通用的
# 在用之前注意一些事项
# TODO: Git config 中的全局用户名和邮箱已经配置完毕
# TODO: Hugo 已经安装，在当前环境变量下可以使用
# TODO: code_address 和 deploy 这两个仓库,确保配置成自己的
# TODO: 确认这两个仓库在Github上已经创建了
# Author: SDTTTTT
######################################################################################
# 如果你是Linux, Mac OS平台，直接运行
# 如果你是 Windows 平台, 请使用`GitBash`来运行该脚本.
# 说一下这个脚本的使用场景，首先你的Hugo项目地址和你的静态网站代码项目地址应该是分开的
# 简单来说一个是你当前项目下打代码仓库，还有一个是打包出来public目录下的代码仓库这个要部署的
#                    仓库变量：code_address                     仓库变量：deploy 
# 使用这个脚本时，你可以不Commit, 脚本会自动帮你Commit, 内容是 $commit_message 可以自定义
# Warning: 该脚本执行时，别按回车!"
# 当然如果你配置了SSH 那你可以不做任何操作 享受自动部署带来打快感吧！
# Enjoy！
#######################################################################################

set -e

code_address="git@github.com:sdttttt/my-site-generator.git" # Hugo 项目地址
deploy="git@github.com:sdttttt/sdttttt.github.io.git" # 静态网站部署地址
commit_message="[SDTTTTT] Update Blog."

dir=$(pwd)

echo "Warning: 该脚本执行时，别按回车!"

if [ -d "./public" -eq 0 ]; then
    rm -rf ./public
fi

function deployToSite(){
    cp -r ./public ../
    cd ../public

    echo "==> [Deploy] Git Runing ..."

    git init
    git add .
    git commit -m "${commit_message}"
    git push $deploy master --force

    if [ ! $? -eq 0 ]; then
        exit
    fi

    cd ..
    rm -rf ./public

    cd $dir

    echo "==> OK Deploy Over :)"
}

echo "==> [Code] Git Runing ... "

git add .
git commit -m "${commit_message}"
git push $code_address master

echo "==> Hugo Building ... \n"
hugo

echo "==> Check Status ..."

if [ $? -eq 0 ]; then
    if [ -d "./public" ]; then
        echo "Check OK :)"
        deployToSite
    else
        echo "Oh! 不应该变成这样 :("
    fi
else 
    echo "环境变量中不存在 hugo: 请安装它"
fi

echo "==> Clean work start!"

rm -rf ./public

echo "==> OK! We is done."
