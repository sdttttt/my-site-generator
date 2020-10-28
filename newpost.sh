#!/bin/bash
# Quick Create Post for My Blog.

set -e

read -p "Input post name: " name
echo -e "\n"

hugo new blog/$name.md