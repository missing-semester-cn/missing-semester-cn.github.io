## question1

提交了一个文件
![pic1](1.png)
发现文件有误
使用reset命令（或git commit --amend来重新提交修改过的文件）
![reset](reset.png)
### 总结

1. reset撤回修改后重新提交
2. revert 版本号

## Question2

1. 修改历史
    1. git reset --soft（只撤销commit）
    2. git commit --amend
2. 不修改历史
   1. git revert
    
    ![revert1](revert1.png)
    ![revert2](revert2.png)


## Question3

1. 合并某分支上的单个commit：git cherry-pick 文件名
2. 在IDEA中合并
