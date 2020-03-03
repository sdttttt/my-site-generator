code_address="https://github.com/sdttttt/my-site-generator.git"
deploy="https://github.com/sdttttt/Site.git"

echo "==> Git Runing ..."

git add .
git commit -m "[SDTTTTT] Update Blog."
git push $code_address master

echo "==> Hugo Building ..."

hugo

echo "==> Check Status ..."

if [ $? -eq 0 ]; then
    if [-e ./public]; then
        echo "Yes"
    else
        echo "Oh! 不应该变成这样"
    fi
else 
    echo "环境变量中不存在 hugo "
fi

echo "==> Clean work start!"

rm -rf public

echo "==> OK! We is done."