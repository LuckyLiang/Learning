---
layout:     post
title:      "MySQL基本使用方法"
subtitle:   ""
description: "这里主要参考官方文档，记录简单用法"
excerpt: ""
date:       2018-10-23 23:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - MySQL
URL: "/2018/10/23/MySqlLeaning/"

---

### 

### MySQL基本使用

安装就不介绍了，网上多的很，这里主要参考[官方文档](https://dev.mysql.com/doc/refman/8.0/en/tutorial.html)，记录简单用法

#### MySQL连接和断开

**连接mysql**

```mysql
mysql -h host -u user -p
Enter password: ********
```

host 连接的服务，我本地调式就是localhost，user：用户名，安装的时候默认用的是root, 然后输入密连接

在同一台机器上使用可以省略host直接使用下面命令连接

```mysql
mysql -u user -p
Enter password: ********
```

**断开连接**

```mysql
mysql> QUIT
Bye
```

在mac上使用 `control + D`快捷键也可退出

**换行和返回上一步**

sql语句使用`；`分号结束，如果不写；直接回车只是换行

```mysql
mysql> SELECT
    -> USER()
```

返回上一步`\c`

```mysql
mysql> SELECT
    -> USER()
    -> \c //直接返回上一行
mysql>
```

#### 创建数据库

**显示所有数据库`SHOW DATABASES;`**

```mysql
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| classicmodels      |
| information_schema |
| menagerie          |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
6 rows in set (0.00 sec)

mysql> 
```

**使用某个数据库 `USE classicmodels**

```mysql
mysql> use classicmodels
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> 
```

**创建和选择一个数据库**

```mysql
mysql> CREATE DATABASE menagerie;
```

**使用刚刚创建的这个数据库**

```mysql
mysql> USE menagerie
Database changed
```

#### 表操作

**显示当前数据库下所有表**

```mysql
mysql> SHOW TABLES;
Empty set (0.00 sec)
```

**创建表**

```mysql
mysql> CREATE TABLE pet (name VARCHAR(20), owner VARCHAR(20),
       species VARCHAR(20), sex CHAR(1), birth DATE, death DATE);
```

```mysql
mysql> SHOW TABLES;
+---------------------+
| Tables_in_menagerie |
+---------------------+
| pet                 |
+---------------------+
1 row in set (0.00 sec)

mysql> 
```

**查看表详细信息 `DESCRIBE tableName`**

```mysql
mysql> DESCRIBE pet;
+---------+-------------+------+-----+---------+-------+
| Field   | Type        | Null | Key | Default | Extra |
+---------+-------------+------+-----+---------+-------+
| name    | varchar(20) | YES  |     | NULL    |       |
| owner   | varchar(20) | YES  |     | NULL    |       |
| species | varchar(20) | YES  |     | NULL    |       |
| sex     | char(1)     | YES  |     | NULL    |       |
| birth   | date        | YES  |     | NULL    |       |
| death   | date        | YES  |     | NULL    |       |
+---------+-------------+------+-----+---------+-------+
6 rows in set (0.01 sec)

mysql> 
```

**插入数据**

```mysql
mysql> INSERT INTO pet
    ->        VALUES ('Puffball','Diane','hamster','f','1999-03-30',NULL);
Query OK, 1 row affected (0.00 sec)

mysql> 
```

**检索表中所有数据 `SELECT * FROM tableNmae`**

```mysql
mysql> SELECT * FROM pet;
+----------+-------+---------+------+------------+-------+
| name     | owner | species | sex  | birth      | death |
+----------+-------+---------+------+------------+-------+
| puffball | Diane | hamster | f    | 1999-03-30 | NULL  |
| Puffball | Diane | hamster | f    | 1999-03-30 | NULL  |
+----------+-------+---------+------+------------+-------+
2 rows in set (0.00 sec)

mysql> 
```

**修改数据`UPDATE`**

```mysql
mysql> UPDATE pet SET birth = '1993-08-23' WHERE name = 'Claws1';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 1  Changed: 0  Warnings: 0

mysql> 
```

**选择特定行**

```mysql
mysql> SELECT * FROM pet WHERE name = 'Bowserl';
+---------+---------+---------+------+------------+-------+
| name    | owner   | species | sex  | birth      | death |
+---------+---------+---------+------+------------+-------+
| Bowserl | Difanea | hamster | m    | 1991-03-30 | NULL  |
+---------+---------+---------+------+------------+-------+
1 row in set (0.00 sec)

mysql> SELECT * FROM pet WHERE birth = '1991-05-19';
+--------+--------+---------+------+------------+-------+
| name   | owner  | species | sex  | birth      | death |
+--------+--------+---------+------+------------+-------+
| Claws2 | louwer | cat     | f    | 1991-05-19 | NULL  |
| Claws3 | louwer | cat     | f    | 1991-05-19 | NULL  |
| Claws4 | louwer | cat     | f    | 1991-05-19 | NULL  |
| Claws5 | louwer | cat     | f    | 1991-05-19 | NULL  |
| Claws6 | louwer | cat     | f    | 1991-05-19 | NULL  |
| Claws7 | louwer | cat     | f    | 1991-05-19 | NULL  |
| Claws8 | louwer | cat     | f    | 1991-05-19 | NULL  |
| Claws9 | louwer | cat     | f    | 1991-05-19 | NULL  |
| Claws  | louwer | cat     | f    | 1991-05-19 | NULL  |
+--------+--------+---------+------+------------+-------+
9 rows in set (0.00 sec)

mysql> 
```

也可以用and和or操作符

```mysql
mysql> SELECT * FROM pet WHERE name = 'Bowserl' OR name = 'Puffball'
    -> ;
+----------+---------+---------+------+------------+-------+
| name     | owner   | species | sex  | birth      | death |
+----------+---------+---------+------+------------+-------+
| Bowserl  | Difanea | hamster | m    | 1991-03-30 | NULL  |
| Puffball | Diane   | hamster | f    | 1999-03-30 | NULL  |
+----------+---------+---------+------+------------+-------+
2 rows in set (0.00 sec)

mysql> SELECT * FROM pet WHERE species = 'cat' AND sex = 'm';
+--------+--------+---------+------+------------+-------+
| name   | owner  | species | sex  | birth      | death |
+--------+--------+---------+------+------------+-------+
| Claws4 | louwer | cat     | m    | 1991-05-19 | NULL  |
| Claws7 | louwer | cat     | m    | 1991-05-19 | NULL  |
+--------+--------+---------+------+------------+-------+
2 rows in set (0.00 sec)

mysql> SELECT * FROM pet WHERE (species = 'cat' AND sex = 'f') OR (species = 'dog' and sex = 'f');
+--------+--------+---------+------+------------+-------+
| name   | owner  | species | sex  | birth      | death |
+--------+--------+---------+------+------------+-------+
| Claws3 | louwer | dog     | f    | 1991-05-19 | NULL  |
| Claws5 | louwer | cat     | f    | 1991-05-19 | NULL  |
| Claws8 | louwer | cat     | f    | 1991-05-19 | NULL  |
| Claws9 | louwer | dog     | f    | 1991-05-19 | NULL  |
| Claws  | louwer | cat     | f    | 1991-05-19 | NULL  |
+--------+--------+---------+------+------------+-------+
5 rows in set (0.00 sec)

mysql> 

```

**选择特定列**

```mysql
mysql> SELECT name , birth FROM pet;
+----------+------------+
| name     | birth      |
+----------+------------+
| Bowserl  | 1991-03-30 |
| Puffball | 1999-03-30 |
| Claws1   | 1993-08-23 |
| Claws2   | 1991-05-19 |
| Claws3   | 1991-05-19 |
| Claws4   | 1991-05-19 |
| Claws5   | 1991-05-19 |
| Claws6   | 1991-05-19 |
| Claws7   | 1991-05-19 |
| Claws8   | 1991-05-19 |
| Claws9   | 1991-05-19 |
| Claws    | 1991-05-19 |
+----------+------------+
12 rows in set (0.00 sec)

```

**过滤相同的`DISTINCT`**

```mysql
mysql> SELECT DISTINCT owner FROM pet;
+---------+
| owner   |
+---------+
| Difanea |
| Diane   |
| louwer  |
+---------+
3 rows in set (0.00 sec)

mysql> 
```

**`WHERE`条件筛选**

```mysql
mysql> SELECT name, species, birth FROM pet WHERE species = 'dog' OR species = 'cat';
+--------+---------+------------+
| name   | species | birth      |
+--------+---------+------------+
| Claws3 | dog     | 1991-05-19 |
| Claws4 | cat     | 1991-05-19 |
| Claws5 | cat     | 1991-05-19 |
| Claws7 | cat     | 1991-05-19 |
| Claws8 | cat     | 1991-05-19 |
| Claws9 | dog     | 1991-05-19 |
| Claws  | cat     | 1991-05-19 |
+--------+---------+------------+
7 rows in set (0.00 sec)

mysql> 

```

**排序**

根据日期排序

```mysql
mysql> mysql> SELECT name, birth FROM pet ORDER BY birth;
+----------+------------+
| name     | birth      |
+----------+------------+
| Bowserl  | 1991-03-30 |
| Claws3   | 1991-05-19 |
| Claws7   | 1991-05-19 |
| Claws    | 1991-05-19 |
| Claws8   | 1992-05-19 |
| Claws2   | 1993-05-19 |
| Claws1   | 1993-08-23 |
| Claws4   | 1996-05-19 |
| Claws9   | 1996-05-19 |
| Claws6   | 1997-05-19 |
| Puffball | 1999-03-30 |
| Claws5   | 1999-05-19 |
+----------+------------+
12 rows in set (0.00 sec)

mysql> 
```

倒序`DESC`

```mysql
mysql> SELECT name, birth FROM pet ORDER BY birth DESC;
+----------+------------+
| name     | birth      |
+----------+------------+
| Claws5   | 1999-05-19 |
| Puffball | 1999-03-30 |
| Claws6   | 1997-05-19 |
| Claws4   | 1996-05-19 |
| Claws9   | 1996-05-19 |
| Claws1   | 1993-08-23 |
| Claws2   | 1993-05-19 |
| Claws8   | 1992-05-19 |
| Claws3   | 1991-05-19 |
| Claws7   | 1991-05-19 |
| Claws    | 1991-05-19 |
| Bowserl  | 1991-03-30 |
+----------+------------+
12 rows in set (0.00 sec)

mysql> 
```

多条件排序

```mysql
mysql> SELECT name, species, birth FROM pet
    ->        ORDER BY species, birth DESC;
+----------+---------+------------+
| name     | species | birth      |
+----------+---------+------------+
| Claws5   | cat     | 1999-05-19 |
| Claws4   | cat     | 1996-05-19 |
| Claws8   | cat     | 1992-05-19 |
| Claws7   | cat     | 1991-05-19 |
| Claws    | cat     | 1991-05-19 |
| Claws9   | dog     | 1996-05-19 |
| Claws3   | dog     | 1991-05-19 |
| Puffball | hamster | 1999-03-30 |
| Claws6   | hamster | 1997-05-19 |
| Claws2   | hamster | 1993-05-19 |
| Bowserl  | hamster | 1991-03-30 |
| Claws1   | has     | 1993-08-23 |
+----------+---------+------------+
12 rows in set (0.00 sec)

mysql> 

```

**日期计算**

使用`TIMESTAMPDIFF()`方法来计算时间差，`CURDATE()` 当前时间

```mysql
mysql> SELECT name, birth, CURDATE(),TIMESTAMPDIFF(YEAR,birth,CURDATE()) AS age FROM pet;
+----------+------------+------------+------+
| name     | birth      | CURDATE()  | age  |
+----------+------------+------------+------+
| Bowserl  | 1991-03-30 | 2018-10-23 |   27 |
| Puffball | 1999-03-30 | 2018-10-23 |   19 |
| Claws1   | 1993-08-23 | 2018-10-23 |   25 |
| Claws2   | 1993-05-19 | 2018-10-23 |   25 |
| Claws3   | 1991-05-19 | 2018-10-23 |   27 |
| Claws4   | 1996-05-19 | 2018-10-23 |   22 |
| Claws5   | 1999-05-19 | 2018-10-23 |   19 |
| Claws6   | 1997-05-19 | 2018-10-23 |   21 |
| Claws7   | 1991-05-19 | 2018-10-23 |   27 |
| Claws8   | 1992-05-19 | 2018-10-23 |   26 |
| Claws9   | 1996-05-19 | 2018-10-23 |   22 |
| Claws    | 1991-05-19 | 2018-10-23 |   27 |
+----------+------------+------------+------+
12 rows in set (0.00 sec)

mysql> 

```

结果筛选和排序

```mysql
mysql>  SELECT name, birth, death,
    ->        TIMESTAMPDIFF(YEAR,birth,death) AS age
    ->        FROM pet WHERE death IS NOT NULL ORDER BY age;
+--------+------------+------------+------+
| name   | birth      | death      | age  |
+--------+------------+------------+------+
| Claws2 | 1993-05-19 | 2001-12-20 |    8 |
+--------+------------+------------+------+
1 row in set (0.00 sec)

mysql> 
```

可用`YEAR(),MONTH(),DAYOFMONTH()`,来获取日期相关信息

```mysql
mysql> SELECT name, birth, MONTH(birth) FROM pet;
+----------+------------+--------------+
| name     | birth      | MONTH(birth) |
+----------+------------+--------------+
| Bowserl  | 1991-03-30 |            3 |
| Puffball | 1999-03-30 |            3 |
| Claws1   | 1993-08-23 |            8 |
| Claws2   | 1993-05-19 |            5 |
| Claws3   | 1991-05-19 |            5 |
| Claws4   | 1996-05-19 |            5 |
| Claws5   | 1999-05-19 |            5 |
| Claws6   | 1997-05-19 |            5 |
| Claws7   | 1991-05-19 |            5 |
| Claws8   | 1992-05-19 |            5 |
| Claws9   | 1996-05-19 |            5 |
| Claws    | 1991-05-19 |            5 |
+----------+------------+--------------+
12 rows in set (0.00 sec)

mysql> 

```

筛选

```mysql
mysql> SELECT name , birth, MONTH(birth) FROM pet WHERE MONTH(birth) = '5';
+--------+------------+--------------+
| name   | birth      | MONTH(birth) |
+--------+------------+--------------+
| Claws2 | 1993-05-19 |            5 |
| Claws3 | 1991-05-19 |            5 |
| Claws4 | 1996-05-19 |            5 |
| Claws5 | 1999-05-19 |            5 |
| Claws6 | 1997-05-19 |            5 |
| Claws7 | 1991-05-19 |            5 |
| Claws8 | 1992-05-19 |            5 |
| Claws9 | 1996-05-19 |            5 |
| Claws  | 1991-05-19 |            5 |
+--------+------------+--------------+
9 rows in set (0.00 sec)

mysql> 

```

**NULL值**

用`IS NULL` 和 `IS NOT NULL` 判断

```mysql
mysql> SELECT 1 IS NULL, 1 IS NOT NULL;
+-----------+---------------+
| 1 IS NULL | 1 IS NOT NULL |
+-----------+---------------+
|         0 |             1 |
+-----------+---------------+
1 row in set (0.00 sec)

mysql> 
```

#### **模式匹配**

使用%加字符来进行匹配

查找name以b开头的，字符写前面

```mysql
mysql> SELECT * FROM pet WHERE name LIKE 'b%';
+---------+---------+---------+------+------------+-------+
| name    | owner   | species | sex  | birth      | death |
+---------+---------+---------+------+------------+-------+
| Bowserl | Difanea | hamster | m    | 1991-03-30 | NULL  |
| Buffy   | louwer  | has     | f    | 1993-08-23 | NULL  |
+---------+---------+---------+------+------------+-------+
2 rows in set (0.00 sec)

mysql> 
```

以fy结尾的，字符写后面

```mysql
mysql> SELECT * FROM pet WHERE name LIKE '%fy';
+-------+--------+---------+------+------------+-------+
| name  | owner  | species | sex  | birth      | death |
+-------+--------+---------+------+------------+-------+
| Buffy | louwer | has     | f    | 1993-08-23 | NULL  |
+-------+--------+---------+------+------------+-------+
1 row in set (0.00 sec)

mysql> 
```

包含aw的字符串 ，字符写中间

```mysql
mysql> SELECT * FROM pet WHERE name LIKE '%aw%';
+--------+--------+---------+------+------------+------------+
| name   | owner  | species | sex  | birth      | death      |
+--------+--------+---------+------+------------+------------+
| Claws2 | louwer | hamster | f    | 1993-05-19 | 2001-12-20 |
| Claws3 | louwer | dog     | f    | 1991-05-19 | NULL       |
| Claws4 | louwer | cat     | m    | 1996-05-19 | NULL       |
| Claws5 | louwer | cat     | f    | 1999-05-19 | NULL       |
| Claws6 | louwer | hamster | m    | 1997-05-19 | NULL       |
| Claws7 | louwer | cat     | m    | 1991-05-19 | NULL       |
| Claws8 | louwer | cat     | f    | 1992-05-19 | NULL       |
| Claws9 | louwer | dog     | f    | 1996-05-19 | NULL       |
| Claws  | louwer | cat     | f    | 1991-05-19 | NULL       |
+--------+--------+---------+------+------------+------------+
9 rows in set (0.00 sec)

mysql> 
```

找出名字包含5个字符的用五个`_`组成

```mysql
mysql> SELECT * FROM pet WHERE name LIKE '_____';
+-------+--------+---------+------+------------+-------+
| name  | owner  | species | sex  | birth      | death |
+-------+--------+---------+------+------------+-------+
| Buffy | louwer | has     | f    | 1993-08-23 | NULL  |
| Claws | louwer | cat     | f    | 1991-05-19 | NULL  |
+-------+--------+---------+------+------------+-------+
2 rows in set (0.00 sec)

mysql> 
```

