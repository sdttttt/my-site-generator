---
title: Azure Pipelines
tags: ["CICD"]
---

Azure Pipelines是一种云服务，可用于自动构建和测试您的代码项目并将其提供给其他用户。它几乎适用于任何语言或项目类型。

Azure Pipelines将持续集成（CI）和持续交付（CD）相结合，以持续不断地测试和构建您的代码并将其交付给任何目标。

Azure Pipelines 支持非常多的语言。

#### Price

如果使用公共项目，则Azure Pipelines是免费的。如果您使用私人项目，则每月可以免费运行多达1800分钟（30小时）的管道作业。了解有关基于并行作业定价的更多信息。

是不是非常的棒呢 o(*////▽////*)q

**请遵循以下基本步骤：**

- 配置Azure Pipelines以使用您的Git存储库。
- 编辑azure-pipelines.yml文件以定义构建。
- 将您的代码推送到版本控制存储库。此操作将启动默认触发器以构建和部署，然后监视结果。


## Ruby

```yaml
# Ruby
# Package your Ruby project.
# Add steps that install rails, analyze code, save build artifacts, deploy, and more:
# https://docs.microsoft.com/azure/devops/pipelines/languages/ruby

trigger:
  branches:
    # 只有以下分支提交才会触发CICD
    include:
      - master
      - sdtttttt
      - CICD
      - depend*
  paths:
    # 只有以下文件提交时不触发CICD
    exclude:
      - README.md
      - appveyor.yml

pool:
  vmImage: 'ubuntu-18.04'

steps:
- task: UseRubyVersion@0
  inputs:
  # 天杀的，微软提供的Ubuntu 镜像已经不支持 Ruby2.6.3
    versionSpec: '>= 2.6.3'

# Rails 内置数据库 SQLite3 需要依赖以下工具
- script: sudo apt-get -yqq install libsqlite3-dev libpq-dev
  displayName: install sqlite3

- script: |
    gem install bundler
    bundle install --retry=3 --jobs=4
  displayName: 'bundle install'

- script: bundle exec rake
  displayName: 'bundle exec rake'
```
