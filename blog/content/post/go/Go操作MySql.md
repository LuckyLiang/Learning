---

layout:     post
title:      "go 操作 mysql"
subtitle:   ""
description: "go 操作mysql的简单用"
excerpt: ""
date:       2018-10-24 23:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/10/24/goOpMysql/"
categories: [ go ]
---

使用Go操作MySQL等数据库，一般有两种方式：一是使用database/sql接口，直接在代码里硬编码sql语句；二是使用gorm，即对象关系映射的方式在代码里抽象的操作数据库。一般推荐使用第二种方式。

### 使用database/sql接口

Go没有内置的驱动支持任何数据库，但是Go定义了database/sql接口，用户可以基于驱动接口开发相应数据库的驱动。但缺点是，直接用 github.com/go-sql-driver/mysql 访问数据库都是直接写 sql，取出结果然后自己拼成对象，使用上面不是很方便，可读性也不好。

常用语句

```go
//driverName参数为数据库驱动名称。
//dataSourceName是连接参数，参数格式如下：
//user:password@tcp(host:port)/dbname?charset=utf8
func Open(driverName, dataSourceName string) (*DB, error)
//Prepare为后续查询或执行操作创建一个准备SQL
func (db *DB) Prepare(query string) (*Stmt, error)
//使用给定参数执行准备的SQL语句
func (s *Stmt) Exec(args ...interface{}) (Result, error)
//使用给定参数执行准备的SQL查询语句
func (s *Stmt) Query(args ...interface{}) (*Rows, error)
//执行SQL操作，query为SQL语句，可以接收可变参数，用于填充SQL语句的某些字段值。
func (db *DB) Exec(query string, args ...interface{}) (Result, error)
//执行SQL查询操作，可以接收多个参数
func (db *DB) Query(query string, args ...interface{}) (*Rows, error)
```

下载包

```
go get github.com/go-sql-driver/mysql
```

我们对上面的user表执行CRUD操作（增、删、改、查）。代码如下所示：

```go
package main

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"time"
)

// 数据连接信息
const (
	USERNAME = "root" //数据库登录用户名
	PASSWORD = "admin123456" //密码
	NETWORK = "tcp"
	SERVER = "127.0.0.1" 
	PORT = 3306
	DATABASE = "userTest" //需要连接的数据库名
)

//userinfo 表结构

type UserInfo struct {
	Id int `json:"id" form:"id"`
	Username string `json:"username" form:"username"`
	Password string `json:"password" form:"password"`
	Status int   `json:"status" form:"status"`      // 0 正常状态， 1删除
	Createtime int64 `json:"createtime" form:"createtime"`

}

func main() {
	// 连接数据库
	conn := fmt.Sprintf("%s:%s@%s(%s:%d)/%s?charset=utf8",USERNAME, PASSWORD, NETWORK, SERVER, PORT, DATABASE)
	DB, err := sql.Open("mysql", conn) //需要导入mysql驱动：_ "github.com/go-sql-driver/mysql"
	if err != nil{
		fmt.Println("connection to mysql failed:", err)
		return
	}

	DB.SetConnMaxLifetime(100*time.Second) //最大连接周期，超时的连接就close
	DB.SetMaxOpenConns(100) //设置最大连接数，如果设置为0就没有限制
	//创建表
	CreateTable(DB)
	InsertData(DB)
	QueryOne(DB)
	QueryMulti(DB)
	UpdateData(DB)
	DeleteData(DB)
}

//创建表
func CreateTable(DB *sql.DB) {

	sql := `CREATE TABLE IF NOT EXISTS users(
	id INT(4) PRIMARY KEY AUTO_INCREMENT NOT NULL,
	username VARCHAR(64),
	password VARCHAR(64),
	status INT(4),
	createtime INT(10)
	); `

	// 执行sql语句
	if _, err := DB.Exec(sql); err != nil {
		fmt.Println("create table failed",err)
		return
	}
	fmt.Println("create table successd")
}

// 插入数据
func InsertData(db *sql.DB) {
	result, err := db.Exec("INSERT INTO users(username, password) values ( ?,? )","test","123456")
	if err != nil{
		fmt.Printf("Insert data failed,err:%v", err)
		return
	}

	lastInsertID,err := result.LastInsertId()    //获取插入数据的自增ID
	if err != nil {
		fmt.Printf("Get insert id failed,err:%v", err)
		return
	}
	fmt.Println("Insert data id:", lastInsertID)

	rowsaffected,err := result.RowsAffected()  //通过RowsAffected获取受影响的行数
	if err != nil {
		fmt.Printf("Get RowsAffected failed,err:%v",err)
		return
	}
	fmt.Println("Affected rows:", rowsaffected)

}

//查询单行
func QueryOne(DB *sql.DB) {
	user := new(UserInfo)   //用new()函数初始化一个结构体对象
	row := DB.QueryRow("select id,username,password from users where id=?", 1)
	//row.scan中的字段必须是按照数据库存入字段的顺序，否则报错
	if err := row.Scan(&user.Id,&user.Username,&user.Password); err != nil {
		fmt.Printf("scan failed, err:%v\n", err)
		return
	}
	fmt.Println("Single row data:", *user)
}

//查询多行
func QueryMulti(DB *sql.DB) {
	user := new(UserInfo)
	rows, err := DB.Query("select id,username,password from users where id = ?", 2)

	defer func() {
		if rows != nil {
			rows.Close()   //关闭掉未scan的sql连接
		}
	}()
	if err != nil {
		fmt.Printf("Query failed,err:%v\n", err)
		return
	}
	for rows.Next() {
		err = rows.Scan(&user.Id, &user.Username, &user.Password)  //不scan会导致连接不释放
		if err != nil {
			fmt.Printf("Scan failed,err:%v\n", err)
			return
		}
		fmt.Println("scan successd:", *user)
	}
}

//更新数据
func UpdateData(DB *sql.DB){
	result,err := DB.Exec("UPDATE users set password=? where id=?","111111",1)
	if err != nil{
		fmt.Printf("Insert failed,err:%v\n", err)
		return
	}
	fmt.Println("update data successd:", result)

	rowsaffected,err := result.RowsAffected()
	if err != nil {
		fmt.Printf("Get RowsAffected failed,err:%v\n",err)
		return
	}
	fmt.Println("Affected rows:", rowsaffected)
}

//删除数据
func DeleteData(DB *sql.DB){
	result,err := DB.Exec("delete from users where id=?",1)
	if err != nil{
		fmt.Printf("Insert failed,err:%v\n",err)
		return
	}
	fmt.Println("delete data successd:", result)

	rowsaffected,err := result.RowsAffected()
	if err != nil {
		fmt.Printf("Get RowsAffected failed,err:%v\n",err)
		return
	}
	fmt.Println("Affected rows:", rowsaffected)
}
```

OK，到这里大家是不是觉得这种实现方式很繁琐，假如要修改某个sql语句需要在代码中修改，这样很麻烦，代码设计也比较糟糕。因此这种方式并不推荐使用。

### 使用GORM

GORM（Object Relation Mapping），即Go语言中的对象关系映射，实际上就是对数据库的操作进行封装，对上层开发人员屏蔽数据操作的细节，开发人员看到的就是一个个对象，大大简化了开发工作，提高了生产效率。如GORM结合Gin等服务端框架使用可以开发出丰富的Rest API等。

安装

```
go get -u github.com/jinzhu/gorm
go get github.com/gin-gonic/gin
```

代码

```go
package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"

	"net/http"
)

var MysqlDB *gorm.DB
// 数据连接信息
const (
	USERNAME = "root"
	PASSWORD = "admin123456"
	NETWORK = "tcp"
	SERVER = "127.0.0.1"
	PORT = 3306
	DATABASE = "userTest"
)

type User struct {
	Id   int    `gorm:"size:11;primary_key;AUTO_INCREMENT;not null" json:"id"`
	Age  int    `gorm:"size:11;DEFAULT NULL" json:"age"`
	Name string `gorm:"size:255;DEFAULT NULL" json:"name"`
}

func main() {
	MysqlDB, err := gorm.Open("mysql",fmt.Sprintf("%s:%s@%s(%s:%d)/%s?charset=utf8",USERNAME, PASSWORD, NETWORK, SERVER, PORT, DATABASE))

	if err != nil {
		fmt.Println("failed to connect database:", err)
		return
	}
	fmt.Println("connet database success")
	MysqlDB.SingularTable(true)
	MysqlDB.AutoMigrate(&User{}) //自动建表
	fmt.Println("create table success")

	defer MysqlDB.Close()

	Router()

}

func Router()  {
	router := gin.Default()
	// 路径映射
	router.GET("/user", InitPage)
	router.POST("/user/create", CreateUser)
	router.GET("/user/list", ListUser)
	router.PUT("/user/update", UpdateUser)
	router.GET("/user/find", GetUser)
	router.DELETE("/user/:id", DeleteUser)
	router.Run(":8080")
}

func InitPage(c *gin.Context)  {
	c.JSON(http.StatusOK,gin.H{
		"message":"pong",
	})

}

func CreateUser(c *gin.Context) {
	var user User
	c.BindJSON(&user) //使用bindJson填充对象
	MysqlDB.Create(&user) //创建对象
	c.JSON(http.StatusOK,&user) //返回首页
}

func UpdateUser(c *gin.Context) {
	var user User
	id := c.PostForm("id") //post方法取相应字段
	err := MysqlDB.First(&user,id).Error //数据库查找主键=ID的第一行
	if err != nil {
		c.AbortWithStatus(404)
		fmt.Println(err.Error())
	}else {
		c.BindJSON(&user)
		MysqlDB.Save(&user) //提交更改
		c.JSON(http.StatusOK,&user)
	}
}

func ListUser(c *gin.Context) {
	var user []User
	line := c.Query("line")
	MysqlDB.Limit(line).Find(&user) //限制查找前line行
	c.JSON(http.StatusOK, &user)
}
func GetUser(c *gin.Context) {
	id := c.Query("id")
	var user User
	err := MysqlDB.First(&user, id).Error
	if err != nil {
		c.AbortWithStatus(404)
		fmt.Println(err.Error())
	} else {
		c.JSON(http.StatusOK, &user)
	}
}

func DeleteUser(c *gin.Context)  {
	id := c.Param("id")
	var user User
	MysqlDB.Where("id = ?", id).Delete(&user)
	c.JSON(http.StatusOK, gin.H{
		"data": "this has been deleted!",
	})
}
```

