---
title: "Paxos算法"
date: 2020-04-27T14:22:38+08:00
tags: ["distributed system"]
draft: true
---

Paxos 算法是分布式系统中比较重要的一个（协议/算法）.
作为分布式一致性代名词的 Paxos 算法号称是最难理解的算法。

## Problem

首先我们需要知道`Paxos`算法解决了一个什么问题？

在一个异步分布式系统中每个`Node`的数据需要尽量保持一致，同时服务又得保持对外可用，这是一个比较脑阔疼的问题，
`Paxos`算法能在可用性和一致性之间保持最佳平衡点。

## Design

在`Paxos`算法体系中，存在三个角色：

- **Proposer**: 负责发起提案(Proposal)，提案带有一个`提案ID`和一个需要同步的值。

- **Acceptor**: 对提案进行裁决，同意或者拒绝。

- **Learner**: 负责学习提案的结果。

**注意:一个进程可以充当多个角色.**

## Description

Paxos 算法过程主要分为 2 个阶段：

**阶段一:** 由`Proposer`选择一个提案 ID 为 a,然后向半数以上的`Acceptor`发起提案 ID 为 a 的 Prepare,
如果一个`Acceptor`收到一个提案 ID 为 X 的 Prepare 请求，它就会遵守一个约定(不再接受比 X 小的提案 ID 的 Prepare, 只接受等于或大于 X 的 Proposal).
