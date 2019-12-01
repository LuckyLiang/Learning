---
layout:     post
title:      "Java（一）- String"
subtitle:   ""
description: "java中string，stringbuffer，stringbuilder学习记录"
excerpt: ""
date:       2017-01-13 19:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - java
URL: "/2017/01/03/java01/"
categories: [ java ]

---

## String类

### 字符串创建

在java中string是字符序列对象，可以通过两种方式创建

1. 通过字面创建

   ```
   String s = "welcome"
   ```

2. 通过`new`关键字

   ```
   String s = new String("Welcome")
   
   char ch[] = {'s','t','r','i','n','g'}
   String s2 = new String(ch)
   	
   ```

通过字面量创建的字符串，会缓存到缓冲池中，当再次创建时会先从缓存池中查找是否有该字符串，如果有直接返回，如果没有先创建再返回

### String不可变性

在java中string对象是不可变的

```
  public static void main(String[] args) {
      String s = "Sachin";
      s.concat(" Tendulkar");
      System.out.println(s); //Sachin,原字符串没有变化，看源码可知是创建了一个新的字符串
  }
```

可以通过重新赋值

```
  public static void main(String[] args) {
      String s = "Sachin";
      s = s.concat(" Tendulkar");
      System.out.println(s); //Sachin Tendulkar
  }
```

### String的比较方法

有三种比较方式

1. 通过`equals()`方法比较

   ```
     public static void main(String[] args) {
           String s1 = "Sachin";
           String s2 = "Sachin";
           String s3 = new String("Sachin");
           String s4 = "Saurav";
           System.out.println(s1.equals(s2));
           System.out.println(s1.equals(s3));
           System.out.println(s1.equals(s4));
       }
   ```

2. 通过`==`操作符比较

   ```
    public static void main(String args[]){  
      String s1="Sachin";  
      String s2="Sachin";  
      String s3=new String("Sachin");  //会在非缓存池中创建实例
      System.out.println(s1==s2);//true 
      System.out.println(s1==s3);//false
    }  
   ```

3. `compareTo()`方法比较

   s1 == s2 return 0;

   s1 > s2 return 1;

   s1 < s2 return -1 

   ```
   public static void main(String args[]){  
      String s1="Sachin";  
      String s2="Sachin";  
      String s3="Ratan";  
      System.out.println(s1.compareTo(s2));//0  
      System.out.println(s1.compareTo(s3));//1(because s1>s3)  
      System.out.println(s3.compareTo(s1));//-1(because s3 < s1 )  
    } 
   ```

   

### 字符串连接

1. 通过`+`连接操作符

   ```
    String s="Sachin"+" Tendulkar";  
    String s=50+30+"Sachin"+40+40;  
   ```

2. 通过`concat()`方法

   ```
   String s1="Sachin ";  
   String s2="Tendulkar";  
   String s3=s1.concat(s2);   
   ```

### 常用方法

#### `substring()`字符串截取

1. `public String substring(int startIndex)`给定起点返回一个新的string
2. `public String substring(int startIndex, int endIndex)`给定起点和终点返回一个新的string对象

```
String s="SachinTendulkar";  
System.out.println(s.substring(6));//Tendulkar  
System.out.println(s.substring(0,6));//Sachin  
```

#### `toUpperCase() and toLowerCase()`

```
String s="Sachin";  
System.out.println(s.toUpperCase());//SACHIN  
System.out.println(s.toLowerCase());//sachin  
System.out.println(s);//Sachin(no change in original) 
```

#### `trim()`去空格

```
String s="  Sachin  ";  
System.out.println(s);//  Sachin    
System.out.println(s.trim());//Sachin  
```

#### `startsWith() and endsWith() `判断开始结尾

```
String s="Sachin";  
System.out.println(s.startsWith("Sa"));//true  
System.out.println(s.endsWith("n"));//true  
```

#### `charAt()`返回特定位置的字符

```
String s="Sachin";  
System.out.println(s.charAt(0));//S  
System.out.println(s.charAt(3));//h  
```

#### ` length()`字符串长度

```
String s="Sachin";  
System.out.println(s.length());//6  
```

#### ` valueOf()`将其他基本数据类型转换为string

比如将 int, long, float, double, boolean, char and char array 转换成string

```
int a=10;  
String s=String.valueOf(a);  
System.out.println(s+10);  
```

#### `replace()`字符串替换

```
String s1="Java is a programming language. Java is a platform. Java is an Island.";    
String replaceString=s1.replace("Java","Kava");//replaces all occurrences of "Java" to "Kava"    
System.out.println(replaceString); 
```

## StringBuffer类

StringBuffer类主要用于创建可变字符串, 主要用于线程安全的

### 构造方法

```
StringBuffer()	
StringBuffer(String str)	
StringBuffer(int capacity)	
```

### 常用方法

```
public synchronized StringBuffer append(String s)	//字符串拼接
public synchronized StringBuffer	insert(int offset, String s)	//字符串插入
public synchronized StringBuffer	replace(int startIndex, int endIndex, String str)	 //字符串替换
public synchronized StringBuffer	delete(int startIndex, int endIndex)	//删除
public synchronized StringBuffer	reverse()	//字符串顺序反转
public int	capacity()	//返回当前字符串容量
public String	substring(int beginIndex)	
public String	substring(int beginIndex, int endIndex)	
```

## StringBuilder类

StringBuilder跟StringBuffer差不多，都是创建可变字符串的，但是StringBuilder不是线程安全的，只要不涉及线程安全问题可以使用StringBuilder，性能会更好一点，其他用法跟StringBuffer差不多

