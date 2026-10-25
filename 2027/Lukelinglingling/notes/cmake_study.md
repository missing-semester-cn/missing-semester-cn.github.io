源代 ⇒ 程序　　　　　　　　　　　　　　　　　　　*-o ⇒ 指定输出*
1. 预处理（修改
2. 编译 ↓ ⇒ .汇编程序（生成
3. 汇编　变成机器码　~~**实现文件的修改**~~　**多个　增量构建**
4. 链接　生成可执行程序（二进制）
　　↳ **就是修改局部，就不用刷新全部东西了.**
makefile. ⇒ 只改改了的
Cmake ⇒ 用简单语言来描述所有平台的建构过程
catkin.
程序的起源：源文件（由 0/1 构成），每 8 个一个字节，一个字节代表一个字符.
只由 ASCII 字符构成的文件是文~~件~~本文件，其他 ⇒ 二进制文件
C 语言 ⇒ 低级语言 ⇒ 可执行目标程序
① 预处理：（~~把~~文件变成 .i 文件）.
1. 展开所有定义
2. 处理预处理 order　e.g. if ifdef elif else endif.
3. #include. ，把文件插入
---
② 编译：进行一系列词法分析，语法分析，语义分析 & 优化 ⇒ .s 文件.
　↳ 汇编语言是一种通用语言.
③ 汇编：把 .s 文件变成机器语言文件（二进制）.
④ 链接：把一堆文件合在一起的东西.（方便模块化）
**CMake 基础.**
用处：管理 C/C++ 编程
核心：CMakeLists~~基础~~.txt.
CMake 指令：命令名（参数列表）
① *cmake_minimum_required(VERSION 3.10).*
② 定义项目和语言 project（项目名，语言）.
　*project.(MyProject CXX.*
③ 添加可执行文件 add_executable（目标名，源文件）.
　*add_executable(MyApp main.cpp utils.cpp)*
④ 添加库 add_library.（目标名 [STATIC | SHARED | MODULE] <源文件
静态：.a / .lib
动态：.so / .dll.
*add_library(MyLib STATIC library.cpp).*
---
⑤ 链接库到目标.（target_link_libraries.(<目标><库>).
　↳ e.g. ~~target~~ *target_link_libraries(MyApp PRIVATE MyLib)*
⑥ 设置变量.
set(<变量名><值>). 后续用 ${name} 引用
⑦. 指定目标路径.
target_include_directories(<目标>.
　[Before | After]
　[SYSTEM]　　　　　　　　　**→ 只有其他**
　[PUBLIC | PRIVATE | INTERFACE]
　**↳ 都行**　　　　　　**↳ 仅当前目标可用该路径**
　<路径>... ).
e.g. ~ *(MyApp PRIVATE ${PROJECT_SOURCE_DIR}/include)*
⑧. install. ↳ (TARGETS <目标>...
　[RUNTIME DESTINATION <可执行文件路径>]
　[LIBRARY DES∼] <动>
　[ARCHIVE ∼.] <静>
　[INCLUDES ∼] <头>)
　　各类型文件位置.
e.g. *install(TARGETS MyApp RUNTIME DESTINATION bin)*
---
条件语句
→ if (<条件>) ... elseif(<条件>) ... else() ... endif()
支持：比较，逻辑运算，变量判断
　↳ if ( ... ).
　　　message(STATUS " ").
　　　set ( ... ).
else ( ).
　　　message (STATUS " ").
　　　set ( ... ).
endif ( ).
自定义命令
add_custom_command (.
　TARGET <目标>
　　PRE_BUILD | PRE_LINK | POST_BUILD
**编译前执行　　　链接前 ∼　　　编译后 ∼**
　COMMAND <命令> [参数 ...]
　[COMMENT <说明>].
　[VERBATIM])
e.g. add_custom_command (
　*TARGET MyApp POST_BUILD*
　*COMMAND ${CMAKE_COMMAND} -E echo " "*
　*COMMENT " "*
　)
---
CMAKE 的变量：① 普通 ∼ ② 缓存 ∼.
普通的~~变量~~作用在当前及其子目录，每次 CMake 运行时~~都~~重置
缓存：持久，在 ~~CMake~~ CMakeCache.txt 中.
可以用 -D 参数修改缓存变量
*$ cmake .. -DMY_INSTALL_PATH=/opt/runoob -DENABLE_LOGGING=OFF.*
※ 找头文件路径 ｛ include_directories(). ⇒ 全局，一般不用
　　　　　　　　｛ ~~tra~~ target_include_directories() ⇒ 仅指定目标
查找库和包.
　↳ *find_package.*
① 找 Boost 库.　REQUIRED. 找不到就中止 CMake 配置.
　*find_package(Boost REQUIRED).*
② 指定 min 版本
　*~~find~~ ∼ (Boost 1.70 REQUIRED).*
③ 指定路径（在指定 path 上搜 OpenCV）.
　*∼ (OpenCV REQUIRED PATHS /path/to/opencv)*
成功后，会有以下内容 ｛ *导入目标：(可用 target_link_libraries).*
　　　　　　　　　　｛ 头文件路径变量 ${Boost_INCLUDE_DIRS}.
　　　　　　　　　　｛ 库文件路径变量 ${Boost_LIBRARY_DIRS}.
---
**※ 优先 target-xxx，另外两个容易路径污染**
始终指定 C++ 标准.（**CMAKE_CXX_STANDARD**）.
并设置 **CMAKE_CXX_STANDARD_REQUIRED 为 ON**.
自身需要的 ⇒ ~~PUBLIC~~ **PRIVATE**.　消费：**INTERFACE**　Both ⇒ **PUBLIC**
缓存变量的值不会更新（要 del build 目录中的 CMakeCache.txt 或 整个目录后 restart）.
---
**使用 AI 编程.**
1. 发送 message.
2. LLM 请求调用工具
3. 本地执行调用
4. 返回 LLM (results)
5. LLM 带着这个上下文 & continue
　　　　　　　　　　　　　　　｝ LLM 只是在 request
　　　　　　　　　　　　　　　｝ 代码才是干活的
三个 core ability：｛ ①. 看到 code.
　　　　　　　　　　｛ ② 在项目中导航.
　　　　　　　　　　｛ ③. 让它能 create & 修改 code.
①. 看文件，给一个文件，然后返回内容 (dictionary).
②. 遍历目录，返回名称 & type.
③ 改文件
工具注册表：TOOL_REGISTRY.
教会 LLM 用这些：这是你的工具，这是格式
双循环：外：input 用户输入，add to history.
　　　　内：调用 LLM till ~~没~~ 有工具 request.
**总结：LLM 决定做什么，代码执行，结果流回去.**
