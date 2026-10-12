# 发布身份

本仓库只允许 GitHub 账号 `baoyan-world` 提交、推送和发布。首次在 clone 中启用时运行：

```sh
scripts/install-publish-guard.sh
```

安装器只写入本仓库的 Git 配置，固定 author/committer、SSH 推送 key 和 `.githooks`。pre-commit 检查提交身份，pre-push 检查提交身份及 GitHub SSH 登录账号；推送分支和 tag 均会经过 pre-push。

创建 GitHub Release 时使用 `scripts/publish-release.sh vX.Y.Z ...`。该入口会同时检查 SSH 与 GitHub CLI 登录账号。不要直接绕过守卫执行发布命令。守卫脚本：`scripts/check-publish-identity.sh`。
