#!/bin/bash

# Hugo 部署脚本 on Github Pages
# 基本是通用的
# 在用之前注意一些事项
# TODO: Git config 中的全局用户名和邮箱已经配置完毕
# TODO: Hugo 已经安装，在当前环境变量下可以使用
# TODO: code_address 和 deploy 这两个仓库,确保配置成自己的
# TODO: 确认这两个仓库在Github上已经创建了
# Author: SDTTTTT

# Enjoy！

code_address="https://github.com/sdttttt/my-site-generator.git" # Hugo 项目地址
deploy="https://github.com/sdttttt/Site.git" # 静态网站部署地址

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
    git commit -m "[SDTTTTT] Update Site."
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
git commit -m "[SDTTTTT] Update Blog."
git push $code_address master

if [ ! $? -eq 0]; then
    exit
fi

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