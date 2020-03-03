code_address="https://github.com/sdttttt/my-site-generator.git"
deploy="https://github.com/sdttttt/Site.git"

dir=$(pwd)

function deployToSite(){
    cp -r ./public ../
    cd ../public

    echo "==> [Deploy] Git Runing ..."

    git init
    git add .
    git commit -m "Update Site ..."
    git push $deploy master

    cd ..
    rm -rfv ./public

    cd $dir

    echo "==> OK Deploy Over :)"
}

echo "==> [Code] Git Runing ..."

git add .
git commit -m "[SDTTTTT] Update Blog."
git push $code_address master

echo "==> Hugo Building ..."

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