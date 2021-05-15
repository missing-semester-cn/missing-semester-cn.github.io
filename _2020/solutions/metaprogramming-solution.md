---
layout: page
title: Solution-元编程
solution: true
---

### 1. 大多数的 makefiles 都提供了 一个名为 clean 的构建目标，这并不是说我们会生成一个名为clean的文件，而是我们可以使用它清理文件，让 make 重新构建。您可以理解为它的作用是“撤销”所有构建步骤。在上面的 makefile 中为paper.pdf实现一个clean 目标。您需要构建phony。您也许会发现 git ls-files 子命令很有用。其他一些有用的 make 构建目标可以在这里找到；

#### 1. 为了编译 LaTeX，首先需要安装 basictex(MacOS)
```bash
brew cask install basictex
```
#### 2. 编写 Makefile
```
paper.pdf: paper.tex plot-data.png
	pdflatex paper.tex

plot-%.png: %.dat plot.py
	./plot.py -i $*.dat -o $@

.PHONY: clean
clean:
	rm *.pdf *.aux *.log *.png
	#git ls-files -o | xargs rm -f
```
```bash
git ls-files -o | xargs rm -f 
```
可以列出没有被 git 追踪的文件，一般是构建的中间产物，当然，需要首先设置 git 的忽略规则。

### 2. 指定版本要求的方法很多，让我们学习一下 [Rust的构建系统](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html)的依赖管理。大多数的包管理仓库都支持类似的语法。对于每种语法(尖号、波浪号、通配符、比较、乘积)，构建一种场景使其具有实际意义；


### 3. Git 可以作为一个简单的 CI 系统来使用，在任何 git 仓库中的 .git/hooks 目录中，您可以找到一些文件（当前处于未激活状态），它们的作用和脚本一样，当某些事件发生时便可以自动执行。请编写一个[pre-commit](https://git-scm.com/docs/githooks#_pre_commit) 钩子，当执行make命令失败后，它会执行 make paper.pdf 并拒绝您的提交。这样做可以避免产生包含不可构建版本的提交信息；

#### 1. 修改`.git/hooks` 目录下面的`pre-commit.sample`文件并将其命名为`pre-commit`
```bash
if  ! make ; then
     echo "build failed, commit rejected"
     exit 1
fi
```
![1.png]({{site.url}}/2020/solutions/images/8/1.png)


### 4. 基于 GitHub Pages 创建任意一个可以自动发布的页面。添加一个GitHub Action 到该仓库，对仓库中的所有 shell 文件执行 shellcheck([方法之一](https://github.com/marketplace/actions/shellcheck))；

![1.png]({{site.url}}/2020/solutions/images/8/2.png)
![1.png]({{site.url}}/2020/solutions/images/8/3.png)
进入仓库的 [action](https://github.com/missing-semester-cn/The-Missing-Solutions/actions) 
页面，修改`blank.yml`
![1.png]({{site.url}}/2020/solutions/images/8/4.png)
```
# This is a basic workflow to help you get started with Actions

name: CI
...
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v2
      # run shellcheck
      - name: ShellCheck
        uses: ludeeus/action-shellcheck@1.1.0
```
执行 action 后，可能会出现错误
![1.png]({{site.url}}/2020/solutions/images/8/5.png)
根据提示修改错误
![1.png]({{site.url}}/2020/solutions/images/8/6.png)
重新执行 action
![1.png]({{site.url}}/2020/solutions/images/8/7.png)

### 5. 构建属于您的 GitHub action，对仓库中所有的.md文件执行 [proselint](http://proselint.com/) 或 [write-good](https://github.com/btford/write-good)，在您的仓库中开启这一功能，提交一个包含错误的文件看看该功能是否生效。

在 Github marketplace 中，可以找到，[Lint Markdown](https://github.com/marketplace/actions/lint-markdown)

修改`blank.yml`
```
# This is a basic workflow to help you get started with Actions

name: CI
...
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v2
      # run shellcheck
      - name: ShellCheck
        uses: ludeeus/action-shellcheck@1.1.0
      - name: Post comment
        uses: mshick/add-pr-comment@v1
        if: ${{ steps.write-good.outputs.result }}
        with:
            message: |
            ${{ steps.write-good.outputs.result }}
            repo-token: ${{ secrets.GITHUB_TOKEN }}
            repo-token-user-login: 'github-actions[bot]' # The user.login for temporary GitHub tokens
            allow-repeats: false # This is the default
```