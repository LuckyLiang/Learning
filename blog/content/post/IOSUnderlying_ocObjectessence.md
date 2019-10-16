---
layout:     post
title:      "IOS底层原理一  探寻OC对象本质"
subtitle:   ""
description: "ios底层原理一 探寻OC对象本质"
excerpt: ""
date:       2018-04-11 09:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - IOS
    - Objective-C
URL: "/2018/04/11/iosunderlying_ocobjectessence/"
categories: [ IOS ]
---
### IOS底层原理总结 - 探寻oc对象的本质



> 面试题：一个NSObject对象占用多少内存？

探寻OC对象的本质，我们平时编写的Objective-C代码，底层实现其实都是C\C++代码。

![1](/img/ocObjectImg01/1.png)

OC的对象结构都是通过基础C\C++的结构体实现的。
我们通过创建OC文件及对象，并将OC文件转化为C++文件来探寻OC对象的本质

OC代码如下：

```objective-c
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSObject *objc = [[NSObject alloc] init];
        //clang -rewrite-objc main.m -o main.cpp // 这种方式没有指定架构例如arm64架构 其中cpp代表（c plus plus）生成 main.cpp
        Class
        NSLog(@"Hello, World!");
    }
    return 0;
}
```

我们通过命令行将OC的mian.m文件转化为c++文件。

方式一：不指定架构

```c
clang -rewrite-objc main.m -o main.cpp // 这种方式没有指定架构例如arm64架构 其中cpp代表（c plus plus）
生成 main.cpp
```

方式二：指定架构模式的命令行，使用xcode工具 xcrun

```c
xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main-arm64.cpp 
//生成 main-arm64.cpp 
```

在转换的main.cpp或者main-arm64.cpp中搜索NSObjcet，可以找到NSObjcet_IMPL（IMPL代表 implementation 实现）

看一下NSObject_IMPL内部

```objective-c
struct NSObject_IMPL {
	Class isa;
};
```

再进入Class查看其本质

```objective-c
typedef struct objc_class *Class;
```

我们发现Class其实就是一个指针，对象底层实现其实就是这个样子



**思考： 一个OC对象在内存中是如何布局的。**
NSObjcet的底层实现，点击NSObjcet进入发现NSObject的内部实现

```objective-c
@interface NSObject <NSObject> {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
    Class isa  OBJC_ISA_AVAILABILITY;
#pragma clang diagnostic pop
}
@end	
```

转化成C语言其实就是一个结构体，在上面的main.cpp中对应的代码为：

```objective-c
struct NSObject_IMPL {
	Class isa;
};
```

> 那么这个结构体占多大的内存空间呢，我们发现这个结构体只有一个成员，isa指针，而指针在64位架构中占8个字节。也就是说一个NSObjec对象所占用的内存是8个字节。到这里我们已经可以基本解答第一个问题。但是我们发现NSObject对象中还有很多方法，那这些方法不占用内存空间吗？其实类的方法等也占用内存空间，但是这些方法所占用的存储空间并不在NSObject对象中。

为了探寻OC对象在内存中如何体现，我们来看下面一段代码

```objective-c
NSObject *objc = [[NSObject alloc] init];
```

上面一段代码在内存中如何体现的呢？上述一段代码中系统为NSObject对象分配8个字节的内存空间，用来存放一个成员isa指针。那么isa指针这个变量的地址就是结构体的地址，也就是NSObjcet对象的地址。
 假设isa的地址为0x100400110，那么上述代码分配存储空间给NSObject对象，然后将存储空间的地址赋值给objc指针。objc存储的就是isa的地址。objc指向内存中NSObject对象地址，即指向内存中的结构体，也就是isa的位置。

```objective-c
#import <Foundation/Foundation.h>
@interface Student : NSObject{
    @public
    int _no;
    int _age;
}
@end

@implementation Student

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        Student *stu = [[Student alloc] init];
        stu -> _no = 4;
        stu -> _age = 5;
        NSLog(@"%@",stu);
    }
    return 0;
}

@end
```

按照上述步骤同样生成c++文件。并查找Student，我们发现Student_IMPL

```c
#ifndef _REWRITER_typedef_Student
#define _REWRITER_typedef_Student
typedef struct objc_object Student;
typedef struct {} _objc_exc_Student;
#endif
extern "C" unsigned long OBJC_IVAR_$_Student$_no;
extern "C" unsigned long OBJC_IVAR_$_Student$_age;
struct Student_IMPL {
	struct NSObject_IMPL NSObject_IVARS;
	int _no;
	int _age;
};
```

发现第一个是 NSObject_IMPL的实现。而通过上面的实验我们知道NSObject_IMPL内部其实就是Class isa
那么我们假设 struct NSObject_IMPL NSObject_IVARS; 等价于 Class isa;

```c
struct Student_IMPL {
    Class *isa;
    int _no;
    int _age;
};
```

因此此结构体占用多少存储空间，对象就占用多少存储空间。因此结构体占用的存储空间为，isa指针8个字节空间+int类型_no 4个字节空间+int类型 _age4个字节空间共16个字节空间

```objective-c
Student *stu = [[Student alloc] init];
stu -> _no = 4;
stu -> _age = 5;
```

那么上述代码实际上在内存中的体现为，创建Student对象首先会分配16个字节，存储3个东西，isa指针8个字节，4个字节的 _no  ,4个字节的 _age

![屏幕快照 2018-11-29 下午2.35.47](/img/ocObjectImg01/屏幕快照 2018-11-29 下午2.35.47.png)

sutdent对象的3个变量分别有自己的地址。而stu指向isa指针的地址。因此stu的地址为0x100400110，stu对象在内存中占用16个字节的空间。并且经过赋值 ,  _no 里面存储4 ， _age里面存储5

验证Student在内存中模样

```objective-c
#import <Foundation/Foundation.h>

struct Student_IMPL {
    Class isa;
    int _no;
    int _age;
};

@interface Student : NSObject{
    @public
    int _no;
    int _age;
}
@end

@implementation Student

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        Student *stu = [[Student alloc] init];
        stu -> _no = 4;
        stu -> _age = 5;
        NSLog(@"%@",stu);
        //强转转化
        struct Student_IMPL *stuImpl = (__bridge struct Student_IMPL *)stu;
        NSLog(@"_no = %d, _age = %d",stuImpl->_no,stuImpl->_age);
    }
    return 0;
}

@end
```

```c
 OC对象本质[3489:409511] <Student: 0x100517d50>
 OC对象本质[3489:409511] _no = 4, _age = 5
Program ended with exit code: 0
```

上述代码将oc对象强转成Student_IMPL的结构体。也就是说把一个指向oc对象的指针，指向这种结构体。由于我们之前猜想，对象在内存中的布局与结构体在内存中的布局相同，那么如果可以转化成功，说明我们的猜想正确。由此说明stu这个对象指向的内存确实是一个结构体。

实际上想要获取对象占用内存的大小，可以通过更便捷的运行时方法来获取。

```objective-c
class_getInstanceSize([Student class])
NSLog(@"%zd,%zd", class_getInstanceSize([NSObject class]) ,class_getInstanceSize([Student class]));
// 打印信息 8和16
```



#### 窥探内存结构

实时查看内存数据	

**方式一：通过打断点。**
Debug Workflow -> viewMemory address中输入stu的地址

![QQ20181129-145349](/img/ocObjectImg01/QQ20181129-145349.png)

从上图中，我们可以发现读取数据从高位数据开始读，查看前16位字节，每四个字节读出的数据为
16进制 0x0000004(4字节) 0x0000005(4字节) isa的地址为 00D1081000001198(8字节)

**方式二：通过lldb指令xcode自带的调试器**

```c
memory read 0x100742af0
// 简写  x 0x100742af0

// 增加读取条件
// memory read/数量格式字节数  内存地址
// 简写 x/数量格式字节数  内存地址
// 格式 x是16进制，f是浮点，d是10进制
// 字节大小   b：byte 1字节，h：half word 2字节，w：word 4字节，g：giant word 8字节

示例：x/4xw    //   /后面表示如何读取数据 w表示4个字节4个字节读取，x表示以16进制的方式读取数据，4则表示读取4次
```

同时也可以通过lldb修改内存中的值

```c
(lldb) memory read 0x100742af0
0x100742af0: 89 11 00 00 01 80 1d 00 04 00 00 00 05 00 00 00  ................
0x100742b00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
(lldb) x/4dw 0x100742af0
0x100742af0: 4489
0x100742af4: 1933313
0x100742af8: 4
0x100742afc: 5
(lldb) memory write 0x100742afc 8
(lldb) po stu->_age
8

(lldb) 
```

> **那么一个NSObject对象占用多少内存？
> NSObjcet实际上是只有一个名为isa的指针的结构体，因此占用一个指针变量所占用的内存空间大小，如果64bit占用8个字节，如果32bit占用4个字节。**

#### 更复杂的继承关系

> 面试题：在64bit环境下， 下面代码的输出内容？

![屏幕快照 2018-11-29 下午3.43.02](/img/ocObjectImg01/屏幕快照 2018-11-29 下午3.43.02.png)



我们发现只要是继承自NSObject的对象，那么底层结构体内一定有一个isa指针。**
 那么他们所占的内存空间是多少呢？单纯的将指针和成员变量所占的内存相加即可吗？上述代码实际打印的内容是16 16，也就是说，person对象和student对象所占用的内存空间都为16个字节。
 其实实际上person对象确实只使用了12个字节。但是因为内存对齐的原因。使person对象也占用16个字节。

> 编译器在给结构体开辟空间时，首先找到结构体中最宽的基本数据类型，然后寻找内存地址能是该基本数据类型的整倍的位置，作为结构体的首地址。将这个最宽的基本数据类型的大小作为对齐模数。
>  为结构体的一个成员开辟空间之前，编译器首先检查预开辟空间的首地址相对于结构体首地址的偏移是否是本成员的整数倍，若是，则存放本成员，反之，则在本成员和上一个成员之间填充一定的字节，以达到整数倍的要求，也就是将预开辟空间的首地址后移几个字节。

> 我们可以总结内存对齐为两个原则：
> **原则 1. 前面的地址必须是后面的地址正数倍,不是就补齐。**
> **原则 2. 整个Struct的地址必须是最大字节的整数倍。**

通过上述内存对齐的原则我们来看，person对象的第一个地址要存放isa指针需要8个字节，第二个地址要存放_age成员变量需要4个字节，根据原则一，8是4的整数倍，符合原则一，不需要补齐。然后检查原则2，目前person对象共占据12个字节的内存，不是最大字节数8个字节的整数倍，所以需要补齐4个字节，因此person对象就占用16个字节空间。

而对于student对象，我们知道sutdent对象中，包含person对象的结构体实现，和一个int类型的_no成员变量，同样isa指针8个字节，_age成员变量4个字节，_no成员变量4个字节，刚好满足原则1和原则2，所以student对象占据的内存空间也是16个字节。

#### OC对象的分类

> 面试题：OC的类信息存放在哪里。
> 面试题：对象的isa指针指向哪里。

示例代码

```objective-c
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@interface Person : NSObject{
    @public
    int _age;
}
@property (nonatomic, assign) int height;
- (void)personMethod;
+ (void)personClassMethod;
@end
@implementation Person
- (void)personMethod {}
+ (void)personClassMethod {}
@end
@interface Student : Person <NSCoding>{
    @public
    int _no;
}
@property (nonatomic, assign) int score;
- (void)studentMethod;
- (void)studentClassMethod;
@end
@implementation Student
- (void)studentMethod{}
- (void)studentClassMethod{}
@end
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject *object1 = [[NSObject alloc] init];
        NSObject *object2 = [[NSObject alloc] init];
        
        Student *stu = [[Student alloc] init];
        [Student load];
        Person *p1 = [[Person alloc] init];
        p1->_age = 10;
        [p1 personMethod];
        [Person personClassMethod];
    
        Person *p2 = [[Person alloc] init];
        p2->_age = 20;
    }
    return 0;
}
```

**OC的类信息存放在哪里**
OC对象主要可以分为三种

1. instance对象（实例对象）
2. class 对象（类对象）
3. meta-class对象（元对象）

**instance对象就是通过类alloc出来的对象，每次调用alloc都会产生新的instance对象**

```c
NSObjcet *object1 = [[NSObjcet alloc] init];
NSObjcet *object2 = [[NSObjcet alloc] init];
```

object1和object2都是NSObject的instace对象（实例对象），但他们是不同的两个对象，并且分别占据着两块不同的内存。
instance对象在内存中存储的信息包括

1. isa对象
2. 其他成员变量

![QQ20181129-155904](/img/ocObjectImg01/QQ20181129-155904.png)

> 衍生问题：在上图实例对象中根本没有看到方法，那么实例对象的方法的代码放在什么地方呢？那么类的方法的信息，协议的信息，属性的信息都存放在什么地方呢？

**class对象**
我们通过class方法或runtime方法得到一个class对象。class对象也就是类对象

```objective-c
		Class objectClass1 = [object1 class];
        Class objectClass2 = [object2 class];
        Class objectClass3 = [NSObject class];
        
        //runtime
        Class objectClass4 = object_getClass(object1);
        Class objectClass5 = object_getClass(object2);
        NSLog(@"%p %p %p %p %p", objectClass1, objectClass2, objectClass3, objectClass4, objectClass5);

```

打印结果：

```objective-c
 OC对象本质[3648:443420] 0x7fff8bea0140 0x7fff8bea0140 0x7fff8bea0140 0x7fff8bea0140 0x7fff8bea0140

Program ended with exit code: 0
```

**通过上面的打印结果可以看出，每一个类在内存中有且只有一个class对象**

class对象在内存中存储的信息主要包括

1. isa指针

2. superclass指针

3. 类的属性信息（@property），类的成员变量信息（ivar）

4. 类的对象方法信息（instance method）,类的协议信息（protocol）

   ![QQ20181129-160904](/img/ocObjectImg01/QQ20181129-160904.png)

**成员变量的值是存储在实例对象中的，因为只有当我们创建实例对象的时候才为成员变赋值。但是成员变量叫什么名字，是什么类型，只需要有一份就可以了。所以存储在class对象中。**

类方法放在那里？
**元类对象 meta-class**

```objective-c
//runtime中传入类对象此时得到的就是元类对象
Class objectMetaClass = object_getClass([NSObject class]);
// 而调用类对象的class方法时得到还是类对象，无论调用多少次都是类对象
Class cls = [[NSObject class] class];
Class objectClass3 = [NSObject class];
class_isMetaClass(objectMetaClass) // 判断该对象是否为元类对象
NSLog(@"%p %p %p", objectMetaClass, objectClass3, cls); // 后面两个地址相同，说明多次调用class得到的还是类对象
```

**每个类在内存中有且只有一个meta-class对象。**
meta-class对象和class对象的内存结构是一样的，但是用途不一样，meta-class在内存中存储的信息主要包括

1. isa指针
2. superclass指针
3. 类的类方法的信息（class method）

![QQ20181129-162321](/img/ocObjectImg01/QQ20181129-162321.png)

**meta-class对象和class对象的内存结构是一样的，所以meta-class中也有类的属性信息，类的对象方法信息等成员变量，但是其中的值可能是空的。**

**对象的isa指针指向哪里**

1. 当对象调用实例方法的时候，我们上面讲到，实例方法信息是存储在class类对象中的，那么要想找到实例方法，就必须找到class类对象，那么此时isa的作用就来了。

   ```c
   [stu studentMethod];
   ```

**instance的isa指向class，当调用对象方法时，通过instance的isa找到class，最后找到对象方法的实现进行调用。**

2. 当类对象调用类方法的时候，同上，类方法是存储在meta-class元类对象中的。那么要找到类方法，就需要找到meta-class元类对象，而class类对象的isa指针就指向元类对象

```c
[Student studentClassMethod];
```

**class的isa指向meta-class当调用类方法时，通过class的isa找到meta-class，最后找到类方法的实现进行调用**

![QQ20181129-162835](/img/ocObjectImg01/QQ20181129-162835.png)

3. 当对象调用其父类对象方法的时候，又是怎么找到父类对象方法的呢？，此时就需要使用到class类对象superclass指针。

```c
[stu personMethod];
[stu init];	
```

当Student的instance对象要调用Person的对象方法时，会先通过isa找到Student的class，然后通过superclass找到Person的class，最后找到对象方法的实现进行调用，同样如果Person发现自己没有响应的对象方法，又会通过Person的superclass指针找到NSObject的class对象，去寻找响应的方法

![QQ20181129-163054](img/ocObjectImg01/QQ20181129-163054.png)

4. 当类对象调用父类的类方法时，就需要先通过isa指针找到meta-class，然后通过superclass去寻找响应的方法

```c
[Student personClassMethod];
[Student load];
```

**当Student的class要调用Person的类方法时，会先通过isa找到Student的meta-class，然后通过superclass找到Person的meta-class，最后找到类方法的实现进行调用**

最后又是这张静定的isa指向图，经过上面的分析我们在来看这张图，就显得清晰明了很多。

![QQ20181129-163231](/img/ocObjectImg01/QQ20181129-163231.png)

> **对isa、superclass总结**
>
> 1. instance的isa指向class
> 2. class的isa指向meta-class
> 3. meta-class的isa指向基类的meta-class，基类的isa指向自己
> 4. class的superclass指向父类的class，如果没有父类，superclass指针为nil
> 5. meta-class的superclass指向父类的meta-class，基类的meta-class的superclass指向基类的class
> 6. instance调用对象方法的轨迹，isa找到class，方法不存在，就通过superclass找父类
> 7. class调用类方法的轨迹，isa找meta-class，方法不存在，就通过superclass找父类



#### 如何证明isa指针的指向真的如上面所说？

我们通过如下代码证明：

```objective-c
NSObject *object = [[NSObject alloc] init];
Class objectClass = [NSObject class];
Class objectMetaClass = object_getClass([NSObject class]);
        
NSLog(@"%p %p %p", object, objectClass, objectMetaClass);
```

打断点并通过控制台打印相应对象的isa指针

```objective-c
        NSObject *object = [[NSObject alloc] init];
        Class objectClass = [NSObject class];
        //元类
        Class objectMetaClass = object_getClass([NSObject class]);
        
        NSLog(@"%p %p %p", object, objectClass, objectMetaClass);
```

打印结果：

```c
OC对象本质[3720:462167] 0x100601e10 0x7fff8bea0140 0x7fff8bea00f0
Program ended with exit code: 0
```

打断点并通过控制台打印相应对象的isa指针

```objective-c
(lldb) p/x object->isa
(Class) $0 = 0x001dffff8bea0141
(lldb) p objectClass
(Class) $1 = 0x00007fff8bea0140
(lldb) 
```

我们发现object->isa与objectClass的地址不同，这是因为从64bit开始，isa需要进行一次位运算，才能计算出真实地址。而位运算的值我们可以通过下载[objc源代码](https://opensource.apple.com/tarballs/objc4/)找到。

![QQ20181129-164628](/img/ocObjectImg01/QQ20181129-164628.png)

我们通过位运算进行验证。

```objective-c
(lldb) p/x object->isa
(Class) $0 = 0x001dffff8bea0141
(lldb) p objectClass
(Class) $1 = 0x00007fff8bea0140
(lldb) p/x 0x00007ffffffffff8 & 0x001dffff8bea0141
(long) $2 = 0x00007fff8bea0140
(lldb) 
```

我们发现，object-isa指针地址0x001dffff96537141经过同0x00007ffffffffff8位运算，得出objectClass的地址0x00007fff96537140

接着我们来验证class对象的isa指针是否同样需要位运算计算出meta-class对象的地址。
当我们以同样的方式打印objectClass->isa指针时，发现无法打印

![QQ20181129-165016](/img/ocObjectImg01/QQ20181129-165016.png)

同时也发现左边objectClass对象中并没有isa指针。我们来到<objc/runtime.h> Class内部看一下

```objective-c
struct objc_class {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class _Nullable super_class                              OBJC2_UNAVAILABLE;
    const char * _Nonnull name                               OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
    struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
    struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;
/* Use `Class` instead of `struct objc_class *` */
```

相信了解过isa指针的同学对objc_class结构体内的内容很熟悉了，今天这里不深入研究，我们只看第一个对象是一个isa指针，为了拿到isa指针的地址，我们自己创建一个同样的结构体并通过强制转化拿到isa指针。

```objective-c
Class objectClass = [NSObject class];
        struct lc_objc_class *lcObjectClass = (__bridge struct lc_objc_class *)objectClass;
```

此时我们重新验证一下

```objective-c
(lldb) p/x lcObjectClass->isa
(Class) $0 = 0x001dffff8bea00f1
(lldb) p/x objectMetaClass
(Class) $1 = 0x00007fff8bea00f0
(lldb) p/x 0x00007ffffffffff8 & 0x001dffff8bea00f1
(long) $2 = 0x00007fff8bea00f0
(lldb) 
```

确实，lcObjectClass的isa指针经过位运算之后的地址是meta-class的地址。

#### 本文面试题总结：

1. 一个NSObject对象占用多少内存？
    答：一个指针变量所占用的大小（64bit占8个字节，32bit占4个字节）
2. 对象的isa指针指向哪里？
    答：instance对象的isa指针指向class对象，class对象的isa指针指向meta-class对象，meta-class对象的isa指针指向基类的meta-class对象，基类自己的isa指针也指向自己。
3. OC的类信息存放在哪里？
    答：成员变量的具体值存放在instance对象。对象方法，协议，属性，成员变量信息存放在class对象。类方法信息存放在meta-class对象。





