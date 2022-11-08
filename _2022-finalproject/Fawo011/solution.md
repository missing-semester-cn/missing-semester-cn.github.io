## First question

- 我完成了文件修改
![image](./1.png)

- 我急不可耐地将test添加到暂存区
![image](./2.png)

- 窝草有错误！
- 这时候运行git reset test.txt
![image](./3.png)
- 直接就是将他移出暂存区
**抑或是git reset --hard**

### 总结
1. 使用git reset
2. 使用git reset --hard

## Second question

- 我直接进行了提交
- ![image](./4.png)
- 确实是有历史的哈
- ![image](./5.png)
- 这时候先用git reset 不保留原有记录
- ![image](./6.png)
- 再提交一次后用git revert
- ![image](./7.png)

### 总结
1. 使用git reset 不保留记录
2. 保留记录使用git revert

## Last question

- 先创建一个分支testing
- ![image](./7.png)
- 进入master后可使用git merge testing 合并
- ![image](./8.png)
- 另一种方法，想了很久，只能想到用git cherry-pick命令了合并testing上的某个提交