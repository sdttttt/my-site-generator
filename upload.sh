#!/bin/bash

set -e

curl -v -F "name=@$1" https://img.vim-cn.com/
