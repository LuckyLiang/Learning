

## Cobra命令行库

项目地址：https://github.com/spf13/cobra.git

文档地址：https://godoc.org/github.com/spf13/cobra#Command

命令行由指令（commands）参数（Args）和标签（flags）组成

遵循的格式为 appName command arg --flag

比如

`hugo server --port=1313`

`git clone URL --bare`

### Commands

指令是程序的核心，程序之间交互都由Command指令完成， 一个command包含子command和可选的运行方法

更多的command见文档地址：https://godoc.org/github.com/spf13/cobra#Command

### Flags

flags标志的是一种修改命令（command）的行为

比如上面的`port`就是端口的一种标志

Flag的功能由[pflag library](https://github.com/spf13/pflag)库提供

### Installing

使用`go get  latest version `  获取该库

```
go get -u github.com/spf13/cobra/cobra
```

在程序中导入

```
import "github.com/spf13/cobra"
```

### Getting Started

使用Cobra来组织您的应用，应用的目录最好是

```go
appName/
	cmd/
		add.go
		your.go
		conmands.go
main.go
```

#### 创建`rootCmd`

```go
package cmd

import (
  "fmt"
	"github.com/spf13/cobra"
)
var (
	rootCmd = &cobra.Command{
  Use:   "hugo",
  Short: "Hugo is a very fast static site generator",
  Long: `A Fast and Flexible Static Site Generator built with
                love by spf13 and friends in Go.
                Complete documentation is available at http://hugo.spf13.com`,
  Run: func(cmd *cobra.Command, args []string) {
    // 这里是命令需要执行的具体任务
			fmt.Println("args = ", args, "需要执行的task在这里")
  }
)

func Execute() error{
	return  rootCmd.Execute()
}
```

在main方法中提供入口

```go
package main
import (
	"fmt"
	"hugoStudy/cmd"
	"os"
)
func main() {

	if err :=  cmd.Execute(); err != nil {
		fmt.Println("err = ", err)
		os.Exit(-1)
	}
}
```

执行`go run main.go`就会执行命令操作，或者编译后执行 `./appName commond`

定义`flags`和在`init()`方法中添加配置



















