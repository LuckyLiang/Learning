## 序列 

> `Sequence` 协议是集合类型结构中的基础。 一个序列 (sequence) 代表的是一系列具有相同类型 的值，你可以对这些值进行迭代。 

```swift
for element in someSequence { 
		doSomething(with: element)
}
```

满足 Sequence 协议的要求十分简单，你需要做的所有事情就是提供一个返回迭代器 (iterator) 的 makeIterator() 方法: 

```swift
protocol Sequence {
	associatedtype Iterator: IteratorProtocol 
	func makeIterator() -> Iterator
// ...
}
```

## 迭代器

序列通过创建一个迭代器来提供对元素的访问。 迭代器每次产生一个序列的值，并且当遍历序 列时对遍历状态进行管理。在 IteratorProtocol 协议中唯一的一个方法是 next()，这个方法需 要在每次被调用时返回序列中的下一个值。当序列被耗尽时，next() 应该返回 nil: 

```swift
protocol IteratorProtocol { 
	associatedtype Element
	mutating func next() -> Element?
}
```

for 循环其实是下面这段代码 的一种简写形式: 

```swift
var iterator = someSequence.makeIterator() 
while let element = iterator.next() {
	doSomething(with: element) 
}
```

迭代器是单向结构，它只能按照增加的方向前进，而不能倒退或者重置 

一个不断返 回同样值的迭代器了: 

```swift
struct ConstantIterator: IteratorProtocol { 
  typealias Element = Int
	mutating func next() -> Int? {
		return 1 
  }
}

var interator = ConstantIterator()
while let x = interator.next() {
    print(x)
}
```

#### 遵守序列协议 

创造有限序列的迭代器  Pre􏰀xGenerator 它将顺次 生成字符串的所有前缀 (也包含字符串本身)。它从字符串的开头开始，每次调用 next 时，会返 回一个追加之后一个字符的字符串切片，直到达到整个字符串尾部为止: 

```swift
struct PrefixIterator: IteratorProtocol {
    let string: String
    var offset: String.Index
    
    init(string: String) {
        self.string = string
        offset = string.startIndex
    }
    
    mutating func next() -> Substring? {
        guard offset < string.endIndex else { return nil }
        offset = string.index(after: offset)
        return string[..<offset]
    }
}
```

(string[..<offset] 是一个对字符串的切片操作，它将返回从字符串开始到偏移量为止的子字符 

有了 Pre􏰀xIterator，定义一个 Pre􏰀xSequence 类型就很容易了。 

```swift
// 遵循序列协议
struct PrefixSequence: Sequence {
    let string: String
    func makeIterator() -> PrefixIterator {
        return PrefixIterator(string: string)
    }
}
//现在，我们可以使用 for 循环来进行迭代，并打印出所有的前缀了:
for prefix in PrefixSequence(string: "hello") {
    print(prefix)
}
/**
h
he
hel
hell
hello
Program ended with exit code: 0
*/
```

