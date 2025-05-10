---
title:  Git Tutorial by Weihua
date: 2024-08-09 12:00:00 +0800
categories: [Tutorial, Git]
tags: [Git]     # TAG names should always be lowercase
---
## 初始化仓库

### 准备条件

1. 本地创建文件夹，git bash 进入文件夹目录
2. Github 仓库创建完成，获取 `<URL>`

```Plaintext
// 初始化
git init
git remote add origin <URL>

git branch -m master main
git pull origin main
```

```Python
//更新链接
git remote set-url origin <URL>
```

```Plaintext
// 新建分支
git branch <own branch>
git checkout <own branch>
git pull origin main

** 删除分支：git branch -d <branch_name> 
```

```Plaintext
// 初次推送
git push (-u) origin kwong

// 常规推送
git status 查看状态
git add .
git commit -m  "xxx:xxx"
git push origin <own branch>
```

## git commit 命名

### 1. 代码类

| commit name | 含义                                                            |
| ----------- | --------------------------------------------------------------- |
| feat        | 添加**新功能**                                            |
| test        | 修改/添加**测试**                                         |
| fix         | 修复**bug**                                               |
| refactor    | **重构**代码（不包括修复 bug 或添加新功能）               |
| perf        | **性能优化**的改动                                        |
| build       | 构建系统工具包或者外部依赖的改动（如修改 webpack、npm scripts） |

### 2. 非代码类

| commit name | 含义                                                         |
| ----------- | ------------------------------------------------------------ |
| docs        | **文档**修改                                           |
| style       | **代码格式**的修改（不影响代码逻辑，如空格、格式调整） |
| chore       | 对构建过程或辅助工具的更改（不影响代码逻辑的修改）           |

### 3. 其它

| commit name | 含义                                     |
| ----------- | ---------------------------------------- |
| test        | 修改现有测试或者添加缺失的测试           |
| ci          | CI（持续集成服务）的配置文件和脚本的更改 |
| revert      | 撤销当前提交                             |

### 4. git commit 书写格式

格式为：`<type>(<scope>): <subject>`

* `type`：提交的类型
* （可选）`scope`：影响的模块或范围
* `subject`：简要描述变更

```JavaScript
// <type>(<scope>): <subject> 举例
// 1. <type>: <subject>
feat: implement token-based authentication
docs: update schema explanation
test: insert into redis database

// 2. <type>(<scope>): <subject>
fix(api): correct POST request error handling
style(ui): apply consistent button styles
perf(log): perf langchain RAG
```

## git merge 指南

**首先，确保你的一切工作都是在你自己的分支上进行！！**

提交结束后，一定记得切回自己的分支

1. 本地分支

```SQL
// 先提交当前你已经完成的工作
git add .
git commit -m "xxx: xxxxxx"
git push origin <own-branch>
```

2. 主分支

```SQL
// 切换到主分支，拉取远程仓库主分支最新状态
git checkout main
git pull origin main

// 合并自己的分支到主分支
git merge <own-branch>
```

这时会进入 MERGING 状态：

`C:\xxx\xxx (<own-branch>|``MERGING``)`

打开文件夹，手动处理合并冲突

处理结束后

```SQL
git add .
git commit -m "merge: xxx - xxxxxx"
git push origin main
```

**记得检查仓库是否更新完成！**

```SQL
git checkout <own-branch>
git pull origin main
```

**一定记得切回自己的分支，git pull origin main**

## .gitignore 内容编辑

```Plain
vim .gitignore
```

## 其它操作

### 版本回退

```Bash
git log 查看版本日志
git reset --hard <commit_id> hard 指的是当前版本

穿梭前，    用git log可以查看提交历史，以便确定要回退到哪个版本。
重返未来，  用git reflog查看命令历史，以便确定要回到未来的哪个版本。
```

```Bash
场景1：当你改乱了工作区某个文件的内容，想直接丢弃工作区的修改时，
    用命令git checkout -- file。
场景2：当你不但改乱了工作区某个文件的内容，还添加到了暂存区时，想丢弃修改，
    分两步，第一步用命令git reset HEAD <file>，
    就回到了场景1，第二步按场景1操作。
场景3：已经提交了不合适的修改到版本库时，想要撤销本次提交，
    参考版本回退一节，不过前提是没有推送到远程库。
```

### 重置分支

```JavaScript
// 恢复工作目录中的所有文件到最后一次提交时的状态。
git restore .
// 从暂存区中移除所有已暂存的更改
git restore --staged .
// 删除所有未跟踪的文件和目录（谨慎使用）。
git clean -fd
// 从远程分支 origin/main 拉取最新的更改并合并到当前分支。
git pull origin main
```

```JavaScript
// 强制情况重置分支
git fetch origin
git reset --hard origin/main
git clean -fd

(可选) git pull origin main --force
```

```JavaScript
// 强制修改分支提交信息记录
git filter-branch -f --env-filter '
OLD_NAME="kwong"
NEW_NAME="waywooKwong"
NEW_EMAIL="2211992@mail.nankai.edu.cn"

if [ "$GIT_COMMITTER_NAME" = "$OLD_NAME" ]
then
    export GIT_COMMITTER_NAME="$NEW_NAME"
    export GIT_COMMITTER_EMAIL="$NEW_EMAIL"
fi
if [ "$GIT_AUTHOR_NAME" = "$OLD_NAME" ]
then
    export GIT_AUTHOR_NAME="$NEW_NAME"
    export GIT_AUTHOR_EMAIL="$NEW_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags

 git push origin main --force-with-lease
```

---

⭐️Copyright@weihua kwong

2024/08/29 v1

2024/10/12 v2
