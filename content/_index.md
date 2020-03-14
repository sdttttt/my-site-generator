---
title: Introduction
type: docs
language: Chinese
date: 2020-03-04
---

# About SDTTTTT

[![GitHub followers](https://img.shields.io/github/followers/sdttttt?style=social)](https://github.com/sdttttt)
[![Twitter URL](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Ftwitter.com%2Fkaierxs)](https://twitter.com/kaierxs)

软件独立开发者, 全栈 💎，熟悉 Go, Java 微服务框架。
Typescript 等部分前端技术栈.

熟悉市场上大部分Web应用架构以及技术栈。
对分布式架构有一定的研究。

目前向网络安全行业转型。

精通`OOP`编程模式.
掌握`Refactoring`, `TDD` 以及大部分软件开发模式.

熟练使用 Git, Docker🐬 等工具.

熟练使用 Linux, Shell.

掌握持续集成工具：Travis, Github Actions, Azure Pipelines.

在下学习能力强，自律性强，喜欢新技术。
能快速适应新环境。

熟悉敏捷开发，极限编程 XP。

## 编码风格

**这是我开发一个软件的生命周期**

1. 思考技术栈选择.
2. 思考软件架构.
3. 细化技术细节.
4. 开始编码.
5. 编写测试.
7. 编写CICD.
8. 发布.

在第4步和第5步中，我会适当的进行重构。

编码规范会严格按照语言官方给出的风格。

## 开源项目

vscode 插件 `Bangumi Open` [![GitHub stars](https://img.shields.io/github/stars/sdttttt/vscode-bangumi?style=social)](https://github.com/sdttttt/vscode-bangumi)
{{< hint info >}}
为了满足一些软件工程师特别嗜好（包括我），我开发了这个插件。
{{< /hint >}}

{{< figure src="./chen.jpg" >}}


{{ if and ( .Site.Params.utteranc.enable ) (and (not .Params.disable_comments) (or (eq .Kind "404") (and (not .IsHome) .Content))) }}
<section class="comments">
<script src="https://utteranc.es/client.js"
        repo="{{ .Site.Params.utteranc.repo }}"
        issue-term="{{ .Site.Params.utteranc.issueTerm }}"
        theme="{{ .Site.Params.utteranc.theme }}"
        crossorigin="anonymous"
        async>
</script>
</section>
{{ end }}