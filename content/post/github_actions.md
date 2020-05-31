---
title: "Github_actions"
date: 2020-03-11T00:50:00+08:00
---

## Github Actions 上传 Releases

```yaml
name: release

# https://help.github.com/en/articles/workflow-syntax-for-github-actions#on
on:
  push:
    tags:
      - '*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: "find env"
      run: |
        set | grep GITHUB_ | grep -v GITHUB_TOKEN
        zip -r pkg.zip *.md
    - uses: xresloader/upload-to-github-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        file: "*.md;*.zip"
        tags: true
        draft: false
        prerelease: true
        overwrite: true
        verbose: true
```