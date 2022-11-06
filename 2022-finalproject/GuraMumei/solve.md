# git应用

## 一、

  1、git reset HEAD -- .  //先撤销暂存区所有文件
     git checkout -- *    //将文件恢复到修改之前内容

  2、git reset --hard HEAD *  //直接回到上一版本

## 二、

  1、修改历史
      git reset --hard HEAD^
      git commit -m _<new>_   //直接覆盖
  2、不修改历史
     git branch <name>
     git checkout _newbranch_
     git reset --hard HEAD^ 
     git commit -m _<new>_    //保存在分支中

##三、
   1、git rebase              
      ![](rebase.png)
   2、git cherry-pick
      ![](cherry-pick.png)

  ~~不知道放什么图就般了度娘的233~~
