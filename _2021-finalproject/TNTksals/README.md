# 自我总结

**总结人**：蔡江弘

**组别**：视觉组

**GitHub ID**：TNTksals

## 前言

- 在接受培训、学习**计算机教育中缺失的一课**（The Missing Semester of Your CS）的过程中，我认识了各种各样的**工具**，并习得了它们的使用方法。使用这些工具不但提高了我完成任务的效率，而且在以后的职业生涯中也起着极为重要的作用。下面是我用学习过程中的笔记所做成的总结，涵盖了一些最主流、最有帮助的工具。

## 工具

### Linux Shell

> **Shell是什么？**

- Shell是一个命令解释器，它通过接受用户输入的shell命令来启动、暂停、停止程序的运行或对计算机进行控制
- Shell是一个应用程序，它连接了用户和Linux内核，让用户能够更加高效、安全、低成本地使用Linux内核

#### 常用基础命令

- `pwd`：查看当前目录
- `cd`：切换目录

- `ls`：显示文件或目录信息
- `mkdir`：当前目录下创建一个空目录
- `rmdir`：要求目录为空
- `touch`：生成一个空文件或更改文件的时间
- `cp`：复制文件或目录
- `mv`：移动文件或目录、文件或目录改名
- `rm`：删除文件或目录
- `ln`：建立链接文件
- `find`：查找文件
- `file/stat`：查看文件类型或文件属性信息
- `cat：`查看文本文件内容
- `more：`可以分页看
- `less：`不仅可以分页，还可以方便地搜索，回翻等操作
- `tail -10`： 查看文件的尾部的10行
- `head -20`：查看文件的头部20行
- `echo`：把内容重定向到指定的文件中 ，有则打开，无则创建

#### 常用系统管理命令

- `stat` 显示指定文件的详细信息，比ls更详细
- `who` 显示在线登陆用户
- `whoami` 显示当前操作用户
- `hostname` 显示主机名
- `top` 动态显示当前耗费资源最多进程信息
- `ps` 显示瞬间进程 ps-aux
- `du` 查看目录大小 du -h /home 带有单位显示目录信息
- `df` 查看磁盘大小 df -h 带有单位显示磁盘信息
- `ifconfig` 查看网络情况
- `ping` 测试网络连通
- `netstat` 显示网络状态信息
- `kill` 杀死进程，可以先用ps或top命令查看进程的id，然后再用kill命令杀死进程

> **grep**

grep（global search regular expression）是一个强大的文本搜索工具。grep使用正则表达式搜索文本，并把匹配的行打印出来。

格式：grep [options] PATTERN [FILE...]

- **PATTERN**是查找条件：可以是普通字符串、可以是正则表达式，通常用单引号括起来
- **FILE**是要查找的文件，可以是用空格间隔的多个文件，也可以使用Shell的通配符在多个文件中查找PATTERN，省略时表示在标准输中查找
- **grep**命令不会对输入文件进行任何修改或影响，可以使用重定向将结果存为文件

例子：

- 在文件myfile中查找包含字符串mystr的行

```bash
grep -n mystr myfile
```

- 显示myfile中第一个字符为字母的所有行

```bash
grep '^[a-zA-A]' myfile
```

- 在文件myfile中查找首字符不是#的行（即过滤掉注释行）

```bash
grep -v '^#' myfile
```

- 列出/etc目录（包括子目录）下所有文件内容中包含字符串“root”的文件名

```bash
grep -lr root /etc/*
```

### Vim程序编辑器

> **介绍**

- Vim是vi文本编辑器的进阶版，在所有Linux系统上均可使用，被称为“编辑器之神”

- Vim通过一些插件可以实现和IDE一样的功能

- Vim可以说是程序开发者的一项很好用的工具

  Vim键盘图：

![Vim键盘图](https://img-blog.csdnimg.cn/img_convert/19c4da683805cd070fdf045e5dba01ab.png)

####  缓存，标签页，窗口

- Vim会维护一系列打开的文件，称为“缓存”。一个Vim会话包含一系列标签页，每个标签页包含一系列窗口（分隔面板）。每个窗口显示一个缓存。缓存和窗口不是一一对应的关系；窗口只是视角。一个缓存可以在多个窗口打开，甚至在同一个标签页内的多个窗口打开。Vim默认打开一个标签页，这个标签也包含一个窗口。
- 使用`Ctrl-W`在多个窗口中切换

#### 编辑模式

- 正常模式：在文本中四处移动光标进行修改
- 插入模式：插入文本
- 替换模式：替换文本
- 可视化（一般，行，块）模式：选中文本块
- 命令模式：用于执行命令

> **正常模式**

- `i` 切换到插入模式，以输入字符(在光标前输入)
- `x` 删除当前光标所在的字符
- `:` 切换到命令模式，以在最后一行输入命令
- `ZZ` 保存并退出

> **插入模式**

- `字符按键以及Shift组合`，输入字符
- `Enter`，回合键，换行
- `Backspace`，退格键，删除光标前一个字符
- `Delete`，删除键，删除光标后一个字符
- `方向键`，在文本中移动光标
- `Esc`，退出插入模式，切换到命令模式

> **命令模式**

- `：q` 退出程序
- `：w` 保存文件
- `：wq` 保存并退出
- `：e {文件名}` 打开要编辑的文件
- `：ls` 显示打开的缓存
- `：help {标题}` 打开帮助文档

#### 键入操作本身是命令

> **移动（正常模式下，使用移动命令在缓存中导航）**

- 基本移动：`hjkl`（方向键：上，下，左，右）
- 词：`w`（下一个词），`b`（词首），`e`（词尾）
- 行：`0`（行首），`^`（第一个非空字符），`$`（行尾）
- 屏幕：`H`（屏幕首行），`M`（屏幕中间），`L`（屏幕底部）
- 翻页：`Ctrl-b`（上翻一页），`Ctrl-f`（下翻一页），`Ctrl-u`（上翻半页），`Ctrl-d`（下翻半页）
- 文件：`gg`（文件头），`G`（文件尾）
- 行数：`{行数}<CR>`，`{行数}G`
- 杂项：`%`（找到配对，比如括号或者/**/之类的注释对）
- `n<space>`：按下数字后再按空格，光标向右移动这一行的n个字符
- `n<Enter>`：光标向下移动n行

> **选择**

- 可视化：`v`
- 可视化行：`V`
- 可视化块：`Ctrl+v`

> **编辑**

- `O/o`：在光标的上方/下方打开新的一行并进入插入模式

- `d{移动命令}`：删除{移动命令}

  例如，`dw` 从光标处删除至一个单词的末尾，`d$` 删除到行尾，`d0` 删除到行头，`dd` 删除光标所在的那一整行

- `c{移动命令}`：改变{移动命令}

  例如，`cw` 改变光标处直到单词末尾

- `x` 删除光标所在处的字符

- `r` 替换单个字符

- `R` 连续替换多个字符（替换模式）

- 可视化模式+操作

  选中文字，`d` 删除或者 `c` 改变

- `u` 撤销，`<Ctrl-R>`重做（撤销以前的撤销命令）

- `y` 复制

  `yy` 复制光标所在的那一整行，`y0` 复制光标所在的那个字符到该行首的所有数据，`y$` 复制光标所在的那个字符到该行尾的所有数据

- `p` 粘贴

- `～` 将光标下的字符改变大小写

> **搜索和替换**

- `/word`：光标向下寻找一个名称为word的字符串
- `？word`：光标向上寻找一个名称为word的字符串
- `:set ic`：忽略大小写
- `:set hls is`：匹配串高亮
- `:nohlsearch`：取消匹配串高亮
- `:set noic`：禁用忽略大小写
- `n`：重复前一个搜寻的动作
- `N`：『反向』进行前一个搜寻动作
- `Ctrl-o`：回退到之前的位置
- `：s/old/new/g`：替换光标所在行的匹配串
- `：%s/old/new/g`：替换整个文件中的每个匹配串

> **命令行补全**

- `Ctrl-D`：查看可能的补全结果
- `<Tab>`：使用一个补全

> **环境变更（命令模式）**

- `:set nu`：在每一行的前缀显示行号
- `:set nonu`：取消行号

> **执行外部命令**

- 输入：! 然后紧接着输入一个外部命令可以执行该外部命令
  例如，`：!ls`

> **多窗口**

- `:sp` / `:vsp`：分割窗口
- `:term bash`：在Vim中打开终端

> **保存文件**

- `：w {未被使用的文件名}`：将已改动的文件保存到当前目录中
- 选择性保存：进入可视化模式选中文本后，按 `:` 字符，将看到屏幕底部会出现 `:'<,'>` ，接着输入 `w {未被使用的文件名}`，确认看到`:'<,'>w {未被使用的文件名}`后，按`<Enter>`，这时 Vim 会把选中的行写入到以 {未被使用的文件名} 命名的文件中去
- 提取：通过命令 `:r {文件名}` 将名为 {文件名} 的文件提取进来，所提取进来的文件将从光标所在位置处开始置入
  还可以读取外部命令的输出，例如， `:r !ls` 可以读取 ls 命令的输出，并把它放置在光标下面

### Shell脚本

#### **介绍**

- Shell脚本是由shell命令组成的执行文件，将一些命令整合到一个文件中，进行处理业务逻辑。脚本不用编译即可运行，它通过解释器解释运行，所以速度相对来说比较慢

> **第一个Shell脚本程序**

```bash
#!/bin/bash
# 上面中的 #! 是一种约定标记, 它可以告诉系统这个脚本需要什么样的解释器来执行;
 
echo "Hello World!"
```

#### **变量**

> **定义变量**

```bash
name="test"
number=100
# 创建普通变量
 
local name="test"
#创建只可函数体中使用的局部变量
 
unset name
# 删除变量
```

> **使用变量**

```bash
echo $name
echo ${name}
 
# 推荐使用大括号版
```

- Bash中的字符通过 ‘ 和 “ 分隔符来定义
- 以 ‘ 定义的字符串为原义字符串，其中的变量不会被转义
- 以 “ 定义的字符串会将变量值进行替换

```bash
foo=bar
echo "$foo"
# 打印 bar
echo '$foo'
# 打印 $foo
```

> **参数**

| 参数处理 | 说明                                    |
| -------- | --------------------------------------- |
| $0       | 脚本名                                  |
| $1到$9   | 脚本的参数.$1是第一个参数，依此类推     |
| $@       | 所有参数                                |
| $#       | 参数个数                                |
| $?       | 前一个命令的返回值                      |
| $$       | 当前脚本的进程识别码                    |
| !!       | 完整的上一条命令，包括参数。例：sudo !! |
| $_       | 上一条命令的最后一个参数                |

> **获取字符串长度**

- 在${}中使用“#”获取长度

```bash
echo ${#name}
# 输出为4
```

#### 数组

> **定义数组**

- Bash支持一维数组, 不支持多维数组, 它的下标从0开始编号. 用下标[n] 获取数组元素

```bash
array_name=(value0 value1 value2 value3)
```

- 也可以单独定义数组的各个分量，可以不使用连续的下标，而且下标的范围没有限制

```bash
array_name[0]=value0
array_name[1]=value1
array_name[2]=value2
```

- 读取某个下标的元素

```bash
${array_name[index]}
```

- 读取数组的全部元素

```bash
${array_name[*]}
#或
${array_name[@]}
```

- 取得数组元素的个数

```bash
length=${#array_name[@]}
#或
length=${#array_name[*]}
```

- 取得数组单个元素的长度

```bash
lengthn=${#array_name[n]}
```

#### 运算符

> **算术运算符**

- 假定变量 a 为 10，变量 b 为 20

| 运算符 | 说明                                | 举例                 |
| ------ | ----------------------------------- | -------------------- |
| +      | 加法                                | 'expr $a + $b'       |
| -      | 减法                                | 'expr $a - $b'       |
| *      | 乘法                                | 'expr $a * $b'       |
| /      | 除法                                | 'expr $b / $a'       |
| %      | 取余                                | 'expr $b % $a        |
| =      | 赋值                                | a=$b                 |
| ==     | 用于比较两个数字，相同则返回 true   | [ $a == $b ]         |
| !=     | 用于比较两个数字，不相同则返回 true | [ $a != $b ]         |
| ++     | 递增                                | let "a++" 或 ((a++)) |

> **关系运算符**

- 只支持数字，不支持字符串，除非字符串的值是数字

| 运算符 | 说明                                                | 举例          |
| ------ | --------------------------------------------------- | ------------- |
| -eq    | 检测两个数是否相等，相等返回 true                   | [ $a -eq $b ] |
| -ne    | 检测两个数是否不相等，不相等返回 true               | [ $a -ne $b ] |
| -gt    | 检测左边的数是否大于右边的，如果是，则返回 true     | [ $a -gt $b ] |
| -lt    | 检测左边的数是否小于右边的，如果是，则返回 true     | [ $a -lt $b ] |
| -ge    | 检测左边的数是否大于等于右边的，如果是，则返回 true | [ $a -ge $b ] |
| -le    | 检测左边的数是否小于等于右边的，如果是，则返回 true | [ $a -le $b ] |

> **字符串运算符**

- 假定变量 a 为 "abc"，变量 b 为 "efg"

| 运算符 | 说明                                       | 举例         |
| ------ | ------------------------------------------ | ------------ |
| =      | 检测两个字符串是否相等，相等返回 true      | [ $a = $b ]  |
| !=     | 检测两个字符串是否不相等，不相等返回 true  | [ $a != $b ] |
| -z     | 检测字符串长度是否为0，为0返回 true        | [ -z $a ]    |
| -n     | 检测字符串长度是否不为 0，不为 0 返回 true | [ -n "$a" ]  |
| $      | 检测字符串是否为空，不为空返回 true        | [ $a ]       |

- 在Bash中进行比较时，尽量使用双方括号**[[ ]]**而不是方括号[ ]，这样会降低犯错的几率，尽管这样并不能兼容sh

#### **条件语句**

> **If语句**

- if [ 表达式 ] then 语句 fi
- if [ 表达式 ] then 语句 else 语句 fi
- if [ 表达式] then 语句 elif[ 表达式 ] then 语句 elif[ 表达式 ] then 语句 …… fi

```bash
a=10
b=20
if [ $a == $b ]
then
   echo "a is equal to b"
else
   echo "a is not equal to b"
fi
```

> **case ... esac语句**

```bash
case 值 in
模式1)
    command1
    command2
    command3
    ;;
模式2）
    command1
    command2
    command3
    ;;
*)
    command1
    command2
    command3
    ;;
esac
```

- 取值后面必须为关键字 in，每一模式必须以右括号结束
- 取值可以为变量或常数
- 如果无一匹配模式，使用星号 * 捕获该值，再执行后面的命令

> **for循环**

- 固定循环：

```bash
for 变量 in 列表
do
    command1
    command2
    ...
    commandN
done
 
# 列表是一组值（数字、字符串等）组成的序列，每个值通过空格分隔
# 每循环一次，就将列表中的下一个值赋给变量
```

- 例如：

```bash
for loop in 1 2 3 4 5
do
    echo "The value is: $loop"
done
 
# 顺序输出当前列表的数字
#!/bin/bash
for FILE in $HOME/.bash*
do
   echo $FILE
done
 
#显示主目录下以 .bash 开头的文件
```

- 数值处理

```bash
for ((初始值； 限制值； 赋值运算))
do
	程序段
done
 
# 初始值：某个变量在循环中的起始值，直接以类似 i=1 设置好
# 限制值：当变量的值在这个限制值的范围内，就继续进行循环，例如 i<=100
# 赋值运算：每做一次循环时，变量也变化，例如i=i+1
```

- 例如：

```bash
#!/bin/bash
 
read -p "Please input a number, I will count for 1+2+...+your_input: " nu
s=0
for ((i=1; i<=${nu}; i=i+1))
do
	s=$((${s}+${i}))
done
echo "The result of '1+2+3+...+${nu}' is ==> ${s}"
 
# 进行从1累加到用户输入的数值的循环
```

> **while循环**

一般格式：

```bash
while condition
do
    command
done
```

#### **函数**

Shell函数必须先定义后使用，定义如下，

```bash
function_name () 
{
    list of commands
    [ return value ]
}
```

- 调用函数只需要给出函数名，不需要加括号
- 函数返回值，可以显式增加return语句；如果不加，会将最后一条命令运行结果作为返回值
- Shell 函数返回值只能是整数，一般用来表示函数执行成功与否，0表示成功，其他值表示失败
- 函数的参数可以通过 $n 得到，如：

```bash
funWithParam(){
    echo "第一个参数为 $1 !"
    echo "第二个参数为 $2 !"
    echo "第十个参数为 $10 !"
    echo "第十个参数为 ${10} !"
    echo "第十一个参数为 ${11} !"
    echo "参数总数有 $# 个!"
    echo "作为一个字符串输出所有参数 $* !"
}
funWithParam 1 2 3 4 5 6 7 8 9 34 73
 
:<<!
 第一个参数为 1 !
 第二个参数为 2 !
 第十个参数为 10 !
 第十个参数为 34 !
 第十一个参数为 73 !
 参数总数有 11 个!
 作为一个字符串输出所有参数 1 2 3 4 5 6 7 8 9 34 73 !
!
# $10 不能获取第十个参数，获取第十个参数需要${10}。当n>=10时，需要使用${n}来获取参数
```

#### **Shell的文件包含**

- Shell 也可以包含外部脚本，将外部脚本的内容合并到当前脚本

```bash
. filename
#或
source filename
```

- 两种方式的效果相同，简单起见，一般使用点号(.)，但是注意点号(.)和文件名中间有一空格
- 被包含脚本不需要有执行权限

#### **重定向**

一般情况下，每个 Unix/Linux 命令运行时都会打开三个文件：

- 标准输入文件(STDIN)：STDIN 的文件描述符为0，Unix程序默认从STDIN读取数据
- 标准输出文件(STDOUT)：STDOUT 的文件描述符为1，Unix程序默认向STDOUT输出数据（返回输出值）
- 标准错误文件(STDERR)：STDERR 的文件描述符为2，Unix程序会向STDERR流中写入错误信息

```bash
$ command 2> file  # STDERR 重定向到 file
$ command 2> file  # STDERR 追加到 file 文件末尾
```

- 如果希望执行某个命令，但又不希望在屏幕上显示输出结果，那么可以将输出重定向到 /dev/null

```bash
$ command > /dev/null
```

- /dev/null 是一个特殊的文件，写入到它的内容都会被丢弃；如果尝试从该文件读取内容，那么什么也读不到。但是 /dev/null 文件非常有用，将命令的输出重定向到它，会起到"禁止输出"的效果.

```bash
$ command > /dev/null 2>&1
# 屏蔽 STDOUT 和 STDERR
```

### 数据整理与命令行环境

#### 数据整理

##### 正则表达式

> **介绍**

- 正则表达式(regular expression)描述了一种字符串匹配的模式（pattern），可以用来检查一个串是否含有某种子串、将匹配的子串替换或者从某个串中取出符合某个条件的子串等
- 正则表达式通常以（尽管并不总是） / 开始和结束

##### 简单字符

- 没有特殊意义的字符都是简单字符，简单字符就代表自身，绝大部分字符都是简单字符

```bash
/abc/ // 匹配 abc
/123/ // 匹配 123
/-_-/ // 匹配 -_-
/梦幻/ // 匹配 梦幻
```

##### 普通字符

| 字符   | 描述                                                         |
| ------ | ------------------------------------------------------------ |
| [ABC]  | 匹配 `[...]` 中的所有字符，例如 `[aeiou]`![img](https://img-blog.csdnimg.cn/1336296585e547a6ae1b127005275e22.png) |
| [^ABC] | 匹配除了 `[...]` 中字符的所有字符，例如 `[^aeiou]` ![img](https://img-blog.csdnimg.cn/906dbc015c89421aa7032cfc9125fad8.png) |
| [A-Z]  | [A-Z] 表示一个区间，匹配所有大写字母，[a-z] 表示所有小写字母![img](https://img-blog.csdnimg.cn/764afbecd2734c28b959715768280d25.png) |
| .      | 匹配除换行符（\n、\r）之外的任何单个字符，相等于 `[^\n\r]`![img](https://img-blog.csdnimg.cn/a666882f2dd243d7852d4d509829af7b.png) |
| [\s\S] | 匹配所有。\s 是匹配所有空白符，包括换行，\S 非空白符，不包括换行![img](https://img-blog.csdnimg.cn/c4e6f721b3f94c8ab18096da10069dc3.png) |
| \w     | 匹配字母、数字、下划线。等价于 [A-Za-z0-9]![img](https://img-blog.csdnimg.cn/27e94a4731914dbd8d115efa1a793e68.png) |

##### 元字符

| 元字符 | 含义                           | 举例    | 说明                 |
| ------ | ------------------------------ | ------- | -------------------- |
| ^      | 匹配行首字符                   | `^x`    | 以字符x开始的字符串  |
| $      | 匹配行尾字符                   | `x$`    | 以字符x结尾的字符串  |
| .      | 匹配除换行符之外的任意单个字符 | `l..e`  | love，life，live ... |
| ?      | 匹配任意一个可选字符           | `xy?`   | x，xy                |
| *      | 匹配前面字符零次或多次重复     | `xy*`   | x，xy，xyy，xyyy ... |
| +      | 匹配前面字符一次或多次重复     | `xy+`   | xy，xyy，xyyy ...    |
| [...]  | 匹配任意一个字符               | `[xyz]` | x，y，z              |
| ()     | 对正则表达式进行分组           | `(xy)+` | xy，xyxy，xyxyxy ... |

| 元字符    | 含义                 | 举例          | 说明                          |
| --------- | -------------------- | ------------- | ----------------------------- |
| `\{n\}`   | 匹配n次              | `go\{2\}gle`  | google                        |
| `\{n,\}`  | 匹配最少n次          | `go\{2,\}gle` | google，gooogle，goooogle ... |
| `\{n,m\}` | 匹配n到m次           | `go\{2,4\}`   | google，gooogle，goooogle     |
| `{n}`     | 匹配n次              | `go{2}gle`    | google                        |
| `{n,}`    | 匹配最少n次          | `go{2,}gle`   | google，gooogle，goooogle ... |
| `{n,m}`   | 匹配n到m次           | `go{2,4}gle`  | google，gooogle，goooogle     |
| `|`       | 以或逻辑连接多个匹配 | `good|bon`    | 匹配good或bon                 |
| `\`       | 转义字符             | `\*`          | *                             |

- 凡是表示范围的量词，都优先匹配上限而不是下限
- 更多关于正则表达式，[这里](https://regexone.com/)有一份简单的教程，推荐学习

```bash
a{1, 3} // 匹配字符串'aaa'的话，会匹配aaa而不是a
a{1, 3}? // 匹配字符串'aaa'的话，会匹配a而不是aaa
```

##### 修饰符（标记）

- 标记也称为修饰符，正则表达式的标记用于指定额外的匹配策略
- 标记不写在正则表达式里，标记位于表达式之外

| 修饰符 | 含义                               | 描述                                                         |
| ------ | ---------------------------------- | ------------------------------------------------------------ |
| i      | ignore - 不区分大小写              | 将匹配设置为不区分大小写，搜索时不区分大小写: A 和 a 没有区别 |
| g      | global - 全局匹配                  | 查找所有的匹配项                                             |
| m      | multi line - 多行匹配              | 使边界字符 `^` 和 `$` 匹配每一行的开头和结尾，记住是多行，而不是整个字符串的开头和结尾 |
| s      | 特殊字符圆点 `.` 中包含换行符 `\n` | 默认情况下的圆点 `.` 是 匹配除换行符 `\n` 之外的任何字符，加上 `s` 修饰符之后, **.** 中包含换行符 \n |

##### 排序命令

> **sort**

```bash
sort [-fbnrtuk] [file or stdin]
```

- -f：忽略大小写
- -b：忽略最前面的空格字符部分
- -n：使用【纯数字】进行排序（默认是以文字形式来排序的）
- -r：反向排序
- u：相同的数据中，仅出现一行代表
- -t：分隔符号，默认是用[Tab]键来分隔
- -k：以哪个区间（field）来进行排序的意思

```bash
cat /etc/passwd | sort
# 将记录在/etc/passwd下的个人账号进行排序
cat /etc/passwd | sort -t ':' -k 3
# 以：来分隔，以第三栏来排序
```

> **uniq**

- 排序完成后，将重复的数据仅列出一个显示

```bash
uniq [-ic]
```

- -i：忽略大小写
- -c：进行计数

```bash
last | cut -d ' ' -f1 | sort | uniq
# 使用last将账号列出，仅取出账号栏，进行排序后仅取出一位
last | cut -d ' ' -f1 | sort | uniq -c
# 计算每个人的登陆总次数
```

##### Sed

> **介绍**

- Sed是一种功能强大的流式文本编辑器
- 每次仅读取一行内容
- Sed 默认不会直接修改源文件数据，而是会将数据复制到缓冲区中，修改也仅限于缓冲区中的数据
- Sed 主要用来自动编辑一个或多个文件、简化对文件的反复操作、编写转换程序等

###### 常用命令

> **替换**

```bash
sed 's/book/books/' file
# book部分是我们需要使用的正则表达式
# books是用于替换匹配结果的文本
```

> **文本注入**

```bash
sed -i 's/book/books/g' file
# 使用后缀 /g 标记会替换每一行中的所有匹配
# 匹配file文件中每一行的所有book替换为books
```

> **打印特定的行**

```bash
sed -n 's/test/TEST/p' file
# 表示只打印那些发生替换的行
```

#### 命令行环境

##### 任务控制

- Shell使用Unix提供的信号机制执行进程间通信
- 当一个进程接收到信号时，它会停止执行、处理该信号并基于信号传递的信息来改变其执行
- `<Ctrl-C>`：结束进程
- `<Ctrl-Z>`：暂停进程
- `fg`：前台继续
- `bg`：后台继续

> **jobs**

- 列出当前终端会话中尚未完成的全部任务
- 基本格式：

```bash
jobs [options]
```

- 常用选项及含义

| 选项 | 含义                                 |
| ---- | ------------------------------------ |
| -l   | 列出进程的 PID 号                    |
| -n   | 只列出上次发出通知后改变了状态的进程 |
| -p   | 只列出进程的 PID 号                  |
| -r   | 只列出运行中的进程                   |
| -s   | 只列出已停止的进程                   |

> **&后缀**

- &后缀让命令直接在后台运行
- 一般格式：

```bash
./test.sh &
```

- 注意，后台的进程仍然是终端进程的子进程，一旦关闭终端，后台的进程也会停止

> **nohup**

- 用于在系统后台不挂断地运行命令，退出终端不会影响程序的运行
- nohup 命令，在默认情况下（非重定向时），会输出一个名叫 nohup.out 的文件到当前目录下，如果当前目录的 nohup.out 文件不可写，输出重定向到 **$HOME/nohup.out** 文件中
- 一般格式：

```bash
nohup ./test.sh &
```

##### 终端多路复用

> **介绍**

- 在终端同时执行多个任务
- 例如：在终端运行编辑器，同时在终端的另一侧执行程序

###### tmux

- 我们每次打开一个 **终端窗口** （screen），可以看作在终端窗口和用户之间建立了一次 **会话** （session），用户在终端窗口中输入命令执行会创建 **进程** ，默认情况下窗口和会话是“绑定的”，也就是说窗口关闭，会话及会话下面的所有进程都会结束。我们经常通过ssh远程连接到服务器，并且执行一些长时间运行的程序，如果网络断开，终端窗口关闭，那么与该窗口关联的会话及其下面的进程都会关闭，这是十分不方便的。
- **tmux可以允许我们基于面板和标签分割出多个终端窗口，这样便可以同时与多个shell会话进行交互**
- **tmux可以将窗口和会话分离，窗口的关闭不会影响到会话的状态，会话中运行的进程也不会被中止，在合适的时候，可以新建窗口连接到之前的会话** 。

结构和工作流

![img](https://img-blog.csdnimg.cn/img_convert/0f0daa5202cbe94a9aad48e3b10cc2dd.png)

> **会话(session)**

- 每一个会话都是一个独立的工作区，其中包含一个或多个窗口
- `tmux` 开始一个新的会话
- `tmux new -s name` 以指定名称开始一个新的会话
- `tmux ls` 列出当前所有会话

> **窗口(window)**

- 相当于编辑器或是浏览器中的标签页，从视觉上将一个会话分割为多个部分
- `<Ctrl-B> c` 创建一个新窗口，使用`<Ctrl-D>` 关闭
- `<Ctrl-B> N` 跳转到第N个窗口
- `<Ctrl-B> p` 切换到前一个窗口
- `<Ctrl-B> n` 切换到下一个窗口
- `<Ctrl-B> ,`重命名当前窗口
- `<Ctrl-B> w` 列出当前所有窗口

> **面板(pan)**

- 像Vim中的分屏一样，面板使我们可以在一个屏幕里显示多个shell
- `<Ctrl-B> "` 水平分割
- `<Ctrl-B> %` 垂直分割
- `<Ctrl-B> <方向>` 切换到指定方向的面板
- `<Ctrl-B> z` 切换当前面板的缩放
- `<Ctrl-B> <space>` 在不同的面板排布间切换
- tmux快速入门教程请看[这里](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/)，以及[这里(包含`screen`命令)](http://linuxcommand.org/lc3_adv_termmux.php)

##### 别名

> **alias**

- 对命令重命名

```bash
alias showmeit="ps -aux"
# 注意，=两边是没有空格的
```

- 解除使用

```bash
unaliax showmeit
```

- 列出目前已有的命令别名

```bash
alias
```

**注意**，在默认情况下shell并不会保存别名，为了让别名持续生效，需要将配置放进shell的启动文件里

##### 远端设备

###### SSH服务

> **简介**

- SSH 是 Secure Shell protocol 的简写 (安全的壳程序协议)，它可以透过数据封包加密技术，将等待传输的封包加密后再传输到网络上

> **连接服务器**

- 一般格式

```bash
[root@www ~]# ssh [-f] [-o 参数项目] [-p 非正规埠口] [账号@]IP [指令]
选项与参数：
-f ：需要配合后面的 [指令] ，不登入远程主机直接发送一个指令过去而已；
-o 参数项目：主要的参数项目有：
	ConnectTimeout=秒数 ：联机等待的秒数，减少等待的时间
	StrictHostKeyChecking=[yes|no|ask]：预设是 ask，若要让 public key
           主动加入 known_hosts ，则可以设定为 no 即可。
-p ：如果你的 sshd 服务启动在非正规的埠口 (22)，需使用此项目；
[指令] ：不登入远程主机，直接发送指令过去。但与 -f 意义不太相同。
 
```

- 直接联机登陆到对方主机

```bash
ssh foo@bar.mit.edu
# 尝试以用户名foo登陆服务器bar.mit.edu
```

- 服务器可以通过URL指定（例如bar.mit.edu），也可以使用IP指定（例如foobar@192.168.1.42）

###### 密钥

> **简介**

- 公钥 (public key)：提供给远程主机进行数据加密的行为，也就是说，**大家都能取得你的公钥来将数据加密**的意思
- 私钥 (private key)：远程主机使用你的公钥加密的数据，在本地端就能够使用私钥来进行解密。由于私钥是这么的重要， **因此私钥是不能够外流的！只能保护在自己的主机上**
- 由于每部主机都应该有自己的密钥 (公钥与私钥)，且公钥用来加密而私钥用来解密， 其中私钥不可外流。但因为网络联机是双向的，所以，每个人应该都要有对方的『公钥』

```bash
# 产生新的服务器端的 ssh 公钥与服务器自己使用的成对私钥
[root@www ~]# rm /etc/ssh/ssh_host*  # 删除密钥档
[root@www ~]# /etc/init.d/sshd restart
正在停止 sshd:                         [  确定  ]
正在产生 SSH1 RSA 主机密钥:            [  确定  ] # 底下三个步骤重新产生密钥！
正在产生 SSH2 RSA 主机密钥:            [  确定  ]
正在产生 SSH2 DSA 主机密钥:            [  确定  ]
正在激活 sshd:                         [  确定  ]
[root@www ~]# date; ll /etc/ssh/ssh_host*
Mon Jul 25 11:36:12 CST 2011
-rw-------. 1 root root  668 Jul 25 11:35 /etc/ssh/ssh_host_dsa_key
-rw-r--r--. 1 root root  590 Jul 25 11:35 /etc/ssh/ssh_host_dsa_key.pub
-rw-------. 1 root root  963 Jul 25 11:35 /etc/ssh/ssh_host_key
-rw-r--r--. 1 root root  627 Jul 25 11:35 /etc/ssh/ssh_host_key.pub
-rw-------. 1 root root 1675 Jul 25 11:35 /etc/ssh/ssh_host_rsa_key
-rw-r--r--. 1 root root  382 Jul 25 11:35 /etc/ssh/ssh_host_rsa_key.pub
# 看一下上面输出的日期与档案的建立时间，刚刚建立的新公钥、私钥系统！
```

> **密钥生成**

- 用户的密钥一般都放在主目录的`.ssh`目录里面

```bash
ssh-keygen  -o -b 4096 [-t rsa|dsa] # 可选 rsa 或 dsa
ssh-keygen -o -a 100 -t ed25519
ssh-keygen  # 用预设的方法建立密钥(rsa)
```

> **基于密钥的认证机制**

- 用户公钥保存在服务器的`~/.ssh/authorized_keys`文件。你要以哪个用户的身份登录到服务器，密钥就必须保存在该用户主目录的`~/.ssh/authorized_keys`文件。只要把公钥添加到这个文件之中，就相当于公钥上传到服务器了
- `ssh` 会查询`~/.ssh/authorized_keys` 来确认哪些用户可以被允许登陆

```bash
cat ~/.ssh/id_rsa.pub | ssh user@host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys" # 文件不存在的情况下
cat .ssh/id_ed25519.pub | ssh foobar@remote 'cat >> ~/.ssh/authorized_keys' 
 
ssh-copy-id -i .ssh/id_ed25519.pub foobar@remote # 自动将公钥拷贝到远程服务器的~/.ssh/authorized_keys文件。如果~/.ssh/authorized_keys文件不存在，ssh-copy-id命令会自动创建该文件
```

- **注意**，`authorized_keys`文件的权限要设为`644`，即只有文件所有者才能写。如果权限设置不对，SSH 服务器可能会拒绝读取该文件

###### 通过SSH复制文件

> **模拟 FTP 的文件传输方式： sftp**

- 这个指令的用法与 ssh 很相似，只是 ssh 是用在登入而 sftp 在上传/下载文件而已

```bash
[root@www ~]# sftp student@localhost
Connecting to localhost...
student@localhost's password: <== 这里请输入密码啊！
sftp> exit  <== 这里就是在等待你输入 ftp 相关指令的地方了！
 
```

> **针对远方服务器主机 (Server) 的命令**

- 常规Linux命令

> **针对本机 (Client) 的命令**

- 在命令前面加上l（L的小写）

> **针对资料上传/下载的命令**

| 将档案由本机上传到远程主机   | put [本机目录或档案] [远程] put [本机目录或档案] 如果是这种格式，则档案会放置到目前远程主机的目录下！ |
| ---------------------------- | ------------------------------------------------------------ |
| **将档案由远程主机下载回来** | **get [远程主机目录或档案] [本机] get [远程主机目录或档案] 若是这种格式，则档案会放置在目前本机所在的目录当中！可以使用通配符，例如： get * get *.rpm 亦是可以的格式！** |

例如：

- 假设 localhost 为远程服务器，且服务器上有 student 这个使用者。你想要 (1)将本机的 /etc/hosts 上传到 student 家目录，并 (2)将 student 的 .bashrc 复制到本机的 /tmp 底下

```bash
[root@www ~]# sftp student@localhost
sftp> lls /etc/hosts   #先看看本机有没有这个档案
/etc/hosts
sftp> put /etc/hosts   #有的话，那就上传吧！
Uploading /etc/hosts to /home/student/hosts
/etc/hosts                        100%  243     0.2KB/s   00:00
sftp> ls               #有没有上传成功？看远程目录下的文件名
hosts
sftp> ls -a            #那有没有隐藏档呢？
.               ..              .bash_history   .bash_logout
.bash_profile   .bashrc         .mozilla        hosts
sftt> lcd /tmp         #切换本机目录到 /tmp 
sftp> lpwd             #只是进行确认而已！
Local working directory: /tmp
sftp> get .bashrc      #没问题就下载吧！
Fetching /home/student/.bashrc to .bashrc
/home/student/.bashrc             100%  124     0.1KB/s   00:00
sftp> lls -a           #看本地端档案档名
.        .font-unix   keyring-rNd7qX  .X11-unix
..       .gdm_socket  lost+found      scim-panel-socket:0-root
.bashrc  .ICE-unix    mapping-root    .X0-lock
sftp> exit             #离开吧！
```

> **档案异地直接复制： scp**

- 通常使用 sftp 是因为可能不知道服务器上面有什么档名的档案存在，如果已经知道服务器上的档案档名了， 那么最简单的文件传输则是透过 scp 这个指令

```bash
[root@www ~]# scp [-pr] [-l 速率] file  [账号@]主机:目录名 <==上传
[root@www ~]# scp [-pr] [-l 速率] [账号@]主机:file  目录名 <==下载
选项与参数：
-p ：保留原本档案的权限数据；
-r ：复制来源为目录时，可以复制整个目录 (含子目录)
-l ：可以限制传输的速度，单位为 Kbits/s ，例如 [-l 800] 代表传输速限 100Kbytes/s
 
# 1. 将本机的 /etc/hosts* 全部复制到 127.0.0.1 上面的 student 家目录内
[root@www ~]# scp /etc/hosts* student@127.0.0.1:~
student@127.0.0.1's password: <==输入 student 密码
hosts                        100%  207         0.2KB/s   00:00
hosts.allow                  100%  161         0.2KB/s   00:00
hosts.deny                   100%  347         0.3KB/s   00:00
# 文件名显示                   进度  容量(bytes) 传输速度  剩余时间
# 你可以仔细看，出现的讯息有五个字段，意义如上所示。
 
# 2. 将 127.0.0.1 这部远程主机的 /etc/bashrc 复制到本机的 /tmp 底下
[root@www ~]# scp student@127.0.0.1:/etc/bashrc /tmp
 
```

###### 端口转发

> **本地端口转发**

- 通过本地计算机访问远程计算机

```bash
ssh -L 8080:127.0.0.1:80 user@webserver
# -L参数表示本地转发，8080是本地端口，80是远程端口
curl http://localhost:8080
# 访问本机的8080端口，就是访问webserver的80端口
```

**注意**，本地端口转发采用 HTTP 协议，不用转成 SOCKS5 协议

> **远程端口转发**

- 通过远程计算机访问本地计算机

```bash
ssh -R 10123:127.0.0.1:123 user@webserver
# -R参数表示远程端口转发，10123是远程端口,123是本地端口
```

> **SSH配置**

- 服务器密钥系统：**/etc/ssh/ssh_host***
- 服务器公钥记录文件：**~/.ssh/known_hosts**
- sshd 服务器细部设定：**/etc/ssh/sshd_config**
- 本机SSH配置：**~/.ssh/config**
- 关于SSH服务，[这里](https://wangdoc.com/ssh/basic.html)有一份资料，[这里](https://www.cnblogs.com/ftl1012/p/ssh.html)的资源也挺不错的。更多关于远程联机服务器，请看[这里](http://cn.linux.vbird.org/linux_server/0310telnetssh.php)。

### 版本管理与安全

#### 代码管理工具Git

> **简介**

- Git 是目前世界上最先进的分布式版本控制系统，用于快速、高效地处理项目版本管理

##### Git的命令行接口

> **基础**

- `git log --all --graph --decorate`：可视化历史记录（有向无环图）
- `git diff`：显示工作目录中当前文件和暂存区文件的差异
- `git diff --staged`：对比已暂存文件和最后一次提交的文件差异
- `git rm --cached <filename>`：将文件从暂存区移除

> **分支与合并**

- `git branch <name>`：新建分支
- `git switch <name>`：切换分支
- `git checkout -b <name>`：创建分支并切换到该分支
- `git branch -d <name>` ：删除分支
- `git merge <revision>`： 合并到当前分支

> **撤销**

- `git commit --amend`：重做最后一次提交的信息
- `git reset HEAD <filename>`：取消暂存的文件
- `git checkout -- <filename>`：撤销文件的修改

> **远端操作**

- `git push <remote> <local branch>:<remote branch>`：将对象传送至远端并更新远端引用
- `git fetch`：从远端获取对象/索引，可以随时合并或查看
- `git pull`: 相当于 `git fetch; git merge`

> **高级操作**

- `git stash`：跟踪文件的修改与暂存的改动，然后将未完成的修改保存到一个栈上，而你可以在任何时候重新应用这些该东（甚至在不同的分支上）

- `git stash pop`：撤销`git stash`的操作

  **应用**：当你在项目的一部分上已经工作一段时间后，所有的东西都进入了混乱的状态，而这时你想切换到另一个分支做一点别的事情。

- `git blame`：指出文件的每一行的最后的变更的提交以及谁是那一个提交的作者

- `git reset --hard HEAD^`：回退到上一个版本

- `git reflog`：分析你所有分支的头指针的日志来找出你在重写历史上可能丢失的提交

##### 拾遗

- 由于众所周知的原因，我们可能无法正常访问https://github.com，因此强烈建议使用特殊的方法研究如何访问和正常使用它，如果不方便进行这些操作，也可以使用国内的Gitee（码云）平台进行学习
- 推荐图形化软件[Gitkraken](https://www.gitkraken.com/)
- 更多关于Git，**强烈推荐**学习[Pro Git](https://git-scm.com/book/en/v2)，以及[Learn Git Branching](https://learngitbranching.js.org/?locale=zh_CN)

#### 安全与密码学

##### 对称加密

> **简介**

- **对称密钥算法**（英语：**Symmetric-key algorithm**）又称为**对称加密**、**私钥加密**、**共享密钥加密**，是[密码学](https://chinois.jinzhao.wiki/wiki/密碼學)中的一类加密算法。这类算法在加密和解密时使用相同的密钥，或是使用两个可以简单地相互推算的密钥。事实上，这组密钥成为在两个或多个成员间的共同秘密，以便维持专属的通信联系[[1\]](https://chinois.jinzhao.wiki/wiki/對稱密鑰加密#cite_note-1)。与[公开密钥加密](https://chinois.jinzhao.wiki/wiki/公开密钥加密)相比，要求双方获取相同的密钥是对称密钥加密的主要缺点之一

> **使用**

- 使用 [OpenSSL](https://www.openssl.org/)的AES模式加密一个文件：

```bash
openssl aes-256-cbc -salt -in {源文件名} -out {加密文件名}
```

- 解密：

```bash
openssl aes-256-cbc -d -in {加密文件名} -out {解密文件名}
```

##### GPG（非对称加密）

> **简介**

- **GNU Privacy Guard**（**GnuPG**或**GPG**）是一个[密码学](https://chinois.jinzhao.wiki/wiki/密码学)软件，用于[加密](https://chinois.jinzhao.wiki/wiki/加密)、[签名](https://chinois.jinzhao.wiki/wiki/數位簽章)通信内容及管理[非对称密码学](https://chinois.jinzhao.wiki/wiki/公开密钥加密)的密钥。GnuPG是[自由软件](https://chinois.jinzhao.wiki/wiki/自由软件)，遵循[IETF](https://chinois.jinzhao.wiki/wiki/互联网工程工作小组)订定的[OpenPGP](https://chinois.jinzhao.wiki/wiki/OpenPGP)技术标准设计，并与[PGP](https://chinois.jinzhao.wiki/wiki/PGP)保持兼容
- GnuPG使用[用户](https://chinois.jinzhao.wiki/wiki/使用者)自行生成的非对称密钥对来加密信息，由此产生的公钥可以同其他用户以各种方式交换，如[密钥服务器](https://chinois.jinzhao.wiki/w/index.php?title=密鑰伺服器&action=edit&redlink=1)。他们必须小心交换密钥，以防止得到伪造的密钥。GnuPG还可以向信息添加一个[数字签名](https://chinois.jinzhao.wiki/wiki/数位签名)，这样，收件人可以验证信息完整性和发件人

> **生成密钥**

```bash
gpg --full-generate-key
# 密钥长度推荐使用默认的 4096
git config --global user.signingkey [公钥ID]
# 设置Git默认使用的密钥来签署标签与提交
```

> **查看密钥**

```bash
$ gpg --list-keys --keyid-format LONG
/home/kslas/.gnupg/pubring.kbx
------------------------------
pub   rsa4096/[公钥ID] 2021-11-02 [SC]
      FB6B847AD7B7D69740F7D7CFB919464B891589FB
uid                 [ 绝对 ] user.name (GPG key) <email@qq.com>
sub   rsa4096/[密钥ID] 2021-11-02 [E]
# 主要用于查看密钥的ID
```

> **获取公钥值**

```bash
$ gpg --armor --export 3AA5C34371567BD2
-----BEGIN PGP PUBLIC KEY BLOCK-----
...
-----END PGP PUBLIC KEY BLOCK-----
# 以‘-----BEGIN PGP PUBLIC KEY BLOCK-----’开头的部分
```

> **Git 提交启用签名**

- 签署提交

```bash
git commit -a -S -m 'signed commit'
git config --global commit.gpgsign true
# 默认启用GPG签名
```

- 验证签名

```bash
git log --show-signature -1
# 签名只对最近一次的提交生效
```

关于GPG，[这里](https://ruanyifeng.com/blog/2013/07/gpg.html)以及[这里](https://frostming.com/2019/11-25/git-commit-sign/)的资料可以学习一下

## 尾言

**感谢**：在学习过程中，我遇到了许多困难，很多时候是我独立解决，但有时候也会向师兄请教，在此感谢师兄们的关照指点。另外特别感谢一位于我而言是亦师亦友的存在—LJC，是他一直以来的帮助，让我走到了今天这一步。

**说明**：文章之所以这么长是因为我早有准备，当初我做笔记时也顺便发到博客上了，最初是CSDN，后来去了博客园，可以看看[我的博客](https://www.cnblogs.com/TNTksals/)。
