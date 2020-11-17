#!/bin/bash
# Quick Create Post for My Blog.

set -e

read -p "Input post name: " name

if [[ -z $name ]]; then
    echo "empty name."
    exit 0
fi

hugo new blog/$name.md