---
layout: page
title: Solution-编辑器 (Vim)
solution: true
---

1. 完成 vimtutor。 备注： 它在一个 80x24（80 列，24 行） 终端窗口看起来最好。
  ```bash
  vimtutor
  ```
2. 下载我们的[vimrc](https://missing-semester-cn.github.io/2020/files/vimrc)，然后把它保存到 `~/.vimrc`。 通读这个注释详细的文件 （用 Vim!）， 然后观察 Vim 在这个新的设置下看起来和使用起来有哪些细微的区别。
3. 安装和配置一个插件： `ctrlp.vim`.
   1. 用 `mkdir -p ~/.vim/pack/vendor/start` 创建插件文件夹
   2. 下载这个插件： `cd ~/.vim/pack/vendor/start; git clone https://github.com/ctrlpvim/ctrlp.vim`   
   下载后需要在~/.vimrc 中添加如下设置，参考[这里](http://ctrlpvim.github.io/ctrlp.vim/#installation)
       ```vim
       set runtimepath^=~/.vim/pack/vendor/start/ctrlp.vim 
       ```
   1. 请阅读这个插件的[文档](https://github.com/ctrlpvim/ctrlp.vim/blob/master/readme.md)。 尝试用 CtrlP 来在一个工程文件夹里定位一个文件， 打开 Vim, 然后用 Vim 命令控制行开始 :CtrlP.  ![1.png]({{site.url}}/2020/solutions/images/3/1.png)
   2. 自定义 CtrlP： 添加 [configuration](https://github.com/ctrlpvim/ctrlp.vim/blob/master/readme.md#basic-options) 到你的 ~/.vimrc 来用按 Ctrl-P 打开 CtrlP
       ```vim
       let g:ctrlp_map ='<c-p>' 
       let g:ctrlp_cmd = 'CtrlP'
       let g:ctrlp_working_path_mode = 'ra' #设置默认路径为当前路径
       ```
       ![1.png]({{site.url}}/2020/solutions/images/3/2.png)
4. 练习使用 Vim, 在你自己的机器上重做演示。
5. 下个月用 Vim 完成_所有_的文件编辑。每当不够高效的时候，或者你感觉 “一定有一个更好的方式”， 尝试求助搜索引擎，很有可能有一个更好的方式。如果你遇到难题， 来我们的答疑时间或者给我们发邮件。
6. 在你的其他工具中设置 Vim 快捷键 （见上面的操作指南）。
7. 进一步自定义你的 ~/.vimrc 和安装更多插件。
  安装插件最简单的方法是使用 Vim 的包管理器，即使用 vim-plug 安装插件：
   1. 安装 vim-plug
    ```bash
    $ curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    ```
   2. 修改 ~/.vimrc
    ```vim
    call plug#begin()
    Plug 'preservim/NERDTree' #需要安装的插件 NERDTree
    Plug 'wikitopian/hardmode'  #安装 hardmode
    ..... # 更多插件
    call plug#end()
    ```
   3. 在 vim 命令行中执行 `:PlugInstall`
 ![1.png]({{site.url}}/2020/solutions//images/3/3.png)
 1. (高阶)用 Vim 宏将 XML 转换到 JSON ([例子文件](https://missing-semester-cn.github.io/2020/files/example-data.xml))。 尝试着先完全自己做，但是在你卡住的时候可以查看上面 [宏](https://missing-semester-cn.github.io/2020/editors/#macros) 章节。  
     1. Gdd, ggdd 删除第一行和最后一行
     2. 格式化最后一个元素的宏 （寄存器 e）             
      跳转到有 `<name>` 的行
           `qe^r"f>s": "<ESC>f<C"<ESC>q`
     3. 格式化一个人的宏             
     跳转到有 `<person>` 的行 `qpS{<ESC>j@eA,<ESC>j@ejS},<ESC>q`
     1. 格式化一个人然后转到另外一个人的宏             
     跳转到有 `<person>` 的行`qq@pjq`
    1. 执行宏到文件尾 `999@q`
    2. 手动移除最后的 , 然后加上 [ 和 ] 分隔符