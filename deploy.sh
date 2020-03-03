#!/bin/bash

# Hugo 部署脚本 on Github Pages
# 基本是通用的
# 在用之前注意一些事项
# TODO: Git config 中的全局用户名和邮箱已经配置完毕
# TODO: Hugo 已经安装，在当前环境变量下可以使用
# TODO: code_address 和 deploy 确保配置成自己的
# Author: SDTTTTT

code_address="https://github.com/sdttttt/my-site-generator.git" # Hugo 项目地址
deploy="https://github.com/sdttttt/Site.git" # 静态网站部署地址

dir=$(pwd)

function deployToSite(){
    cp -r ./public ../
    cd ../public

    echo "==> [Deploy] Git Runing ...\n"

    git init
    git add .
    git commit -m "[SDTTTTT] Update Site."
    git push $deploy master --force

    cd ..
    rm -rf ./public

    cd $dir

    echo "==> OK Deploy Over :) \n"
}

echo "==> [Code] Git Runing ... \n"

git add .
git commit -m "[SDTTTTT] Update Blog."
git push $code_address master

echo "==> Hugo Building ... \n"

hugo

echo "==> Check Status ... \n"

if [ $? -eq 0 ]; then
    if [ -d "./public" ]; then
        echo "Check OK :) \n"
        deployToSite
    else
        echo "Oh! 不应该变成这样 :( \n"
    fi
else 
    echo "环境变量中不存在 hugo: 请安装它 \n"
fi

echo "==> Clean work start! \n"

rm -rf ./public

echo "==> OK! We is done. \n"