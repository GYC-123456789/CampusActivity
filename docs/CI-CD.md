# CampusHub CI/CD

本文档说明 CampusHub 当前推荐的发布方式

## 1. 当前已实现内容总览

当前项目已经实现一套适合本项目服务器环境的 CI/CD 流程：

- CI：代码推送或 PR 时自动检查 Web、Java 后端、Python Agent、App 配置和 Docker 镜像构建。
- CD：通过 GitHub Actions 的 `workflow_dispatch` 手动触发生产发布。
- 发布方式：GitHub Actions 或本地机器构建 Docker 镜像，打包上传到服务器，服务器只执行 `docker load` 和 `docker compose up`。
- 版本标识：生产镜像默认使用 Git commit 短 SHA 作为 release tag。
- 回滚方式：服务器保留当前 tag 和上一个 tag，可通过脚本回滚。
- 验证方式：发布后自动执行 smoke test，检查首页和核心 API。

这套流程避免了服务器外网不稳定导致的依赖安装、镜像拉取失败问题。

## 2. 推荐开发流程

日常开发建议按这个顺序：

```text
main
  -> 新建 feature 分支
  -> 本地开发和自测
  -> git commit
  -> git push
  -> GitHub CI 自动检查
  -> 合并回 main
  -> 手动触发 Deploy workflow
  -> 发布到服务器
```

示例：

```bash
git checkout -b feature/order-filter
git add .
git commit -m "Add order filter"
git push origin feature/order-filter
```

合并到 `main` 后，再到 GitHub Actions 中手动触发生产发布。

## 3. 推荐发布链路

服务器外网访问不稳定，所以生产发布不依赖服务器拉源码、拉依赖或拉镜像。

推荐链路：

```text
GitHub Actions 或本地机器构建 Docker 镜像
  -> docker save 打包镜像
  -> scp 上传到服务器
  -> 服务器 docker load
  -> docker compose 按 release tag 重启服务
  -> smoke test 验证网页和 API
```

生产服务器路径：

```text
/home/ubuntu/CampusHub
```

真实密钥文件：

```text
/home/ubuntu/CampusHub/.env.prod
```

该文件不要提交到 Git。

服务器上的生产入口：

```text
http://124.220.81.104/
```

当前默认 smoke test 使用服务器公网 IP：

```text
http://124.220.81.104
```

## 4. GitHub Actions

### CI

`.github/workflows/ci.yml` 会在 push、PR、手动触发时检查：

- Java 后端能否编译
- Web 前端能否构建
- Agent 能否安装依赖并导入 FastAPI app
- App 端 JSON 配置能否解析
- 三个生产 Docker 镜像能否构建

触发方式：

```text
push 到 main
pull_request
workflow_dispatch
```

CI 不部署，只回答一个问题：这次代码是否具备构建和进入发布流程的基本条件。

### CD

`.github/workflows/deploy.yml` 只支持手动触发：

```text
Actions -> Deploy -> Run workflow
```

可选输入：

- `release_tag`：留空则默认使用当前 Git commit 短 SHA
- `public_base_url`：默认 `http://124.220.81.104`

需要在 GitHub 仓库 Secrets 中配置：

```text
DEPLOY_HOST      124.220.81.104
DEPLOY_USER      ubuntu
DEPLOY_PORT      22
DEPLOY_SSH_KEY   可登录服务器的私钥
```

CD workflow 的实际步骤：

```text
1. Checkout 代码
2. 解析 release tag
3. 构建 campushub-agent:<tag>
4. 构建 campushub-backend:<tag>
5. 构建 campushub-web:<tag>
6. docker save 并 gzip 成镜像包
7. 通过 SSH/SCP 上传到服务器
8. 在服务器执行 deploy-release.sh
9. 服务器 docker load
10. docker compose --no-build 启动新版本
11. GitHub Runner 从公网执行 smoke test
```

发布成功后，服务器会记录当前 tag：

```text
/home/ubuntu/CampusHub/.env.release
```

上一个 tag 会记录在：

```text
/home/ubuntu/CampusHub/.env.release.previous
```

## 5. 镜像版本规则

生产 compose 中三个服务都支持镜像 tag：

```yaml
campushub-agent:${CAMPUSHUB_IMAGE_TAG:-latest}
campushub-backend:${CAMPUSHUB_IMAGE_TAG:-latest}
campushub-web:${CAMPUSHUB_IMAGE_TAG:-latest}
```

CI/CD 发布时会把 `CAMPUSHUB_IMAGE_TAG` 设置为 release tag。默认 release tag 是当前 Git commit 短 SHA，例如：

```text
a1b2c3d
```

这样可以明确知道服务器当前跑的是哪次提交，也方便回滚。

## 6. 本地手动发布

在 Windows PowerShell 中执行。

### 构建镜像

```powershell
.\scripts\build-images.ps1
```

如果 Windows 拦截脚本执行，可以使用：

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\build-images.ps1
```

默认 tag 是当前 Git 短 SHA。也可以指定：

```powershell
.\scripts\build-images.ps1 -Tag test-001
```

同时打 `latest`：

```powershell
.\scripts\build-images.ps1 -AlsoLatest
```

### 保存镜像包

```powershell
.\scripts\save-images.ps1
```

输出在：

```text
artifacts/campushub-images-<tag>.tar
```

### 上传并部署

```powershell
.\scripts\deploy-images.ps1
```

指定 tag：

```powershell
.\scripts\deploy-images.ps1 -Tag test-001
```

部署脚本会上传镜像包、同步 compose 和服务器脚本，然后远程执行发布。

本地手动部署适合两种场景：

- GitHub Actions 暂时不可用。
- 你想学习完整镜像构建和上传过程。

### 本地冒烟测试

```powershell
.\scripts\smoke-test.ps1
```

或：

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\smoke-test.ps1
```

测试内容：

- 首页：`http://124.220.81.104/`
- API：`/api/v1/orders?page=1&size=1`

## 7. 服务器端命令

### 查看服务

```bash
cd /home/ubuntu/CampusHub
sudo docker compose -f docker-compose.prod.yml --env-file .env.prod ps
```

如果要按当前 release tag 查看：

```bash
cd /home/ubuntu/CampusHub
export CAMPUSHUB_IMAGE_TAG="$(sed -n 's/^CAMPUSHUB_IMAGE_TAG=//p' .env.release)"
sudo -E docker compose -f docker-compose.prod.yml --env-file .env.prod ps
```

### 回滚

回滚到上一个版本：

```bash
cd /home/ubuntu/CampusHub
scripts/server/rollback-release.sh
```

回滚到指定版本：

```bash
cd /home/ubuntu/CampusHub
scripts/server/rollback-release.sh <release-tag>
```

### 服务器端脚本说明

```text
scripts/server/deploy-release.sh
```

加载镜像包，写入 `.env.release`，用指定 tag 启动生产服务，并执行服务器内部 smoke test。

```text
scripts/server/rollback-release.sh
```

回滚到 `.env.release.previous` 记录的上一个版本，或回滚到指定 tag。

```text
scripts/server/smoke-test.sh
```

检查首页和 `/api/v1/orders?page=1&size=1`。

由于服务器之前存在 TUN 代理影响公网回包，服务器内部 smoke test 默认使用：

```text
http://127.0.0.1
```

外部公网 smoke test 由 GitHub Actions Runner 或本地机器执行。

## 8. 生产服务器目录约定

```text
/home/ubuntu/CampusHub/
  .env.prod                  # 生产密钥和环境变量，不提交
  .env.release               # 当前发布 tag
  .env.release.previous      # 上一个发布 tag
  docker-compose.prod.yml
  releases/                  # 镜像包
  backups/                   # 回滚记录
  scripts/server/            # 服务器部署工具
```

Docker volume：

```text
campushub_db_data            # MySQL 数据
campushub_backend_uploads    # 用户上传文件
```

发布和回滚不会主动清空数据库和上传文件。

## 9. 注意事项

- `.env.prod` 只放在服务器，不进 Git。
- `.env.prod.example` 只保存示例值和字段说明。
- 不要把 MySQL、后端 8080、Agent 5001 直接暴露到公网。
- 当前公网入口只开放 HTTP 80。
- 如果后续启用 HTTPS，需要新增 443 安全组规则、证书申请和 Nginx HTTPS 配置。
- 当前服务器上的 Clash/Mihomo TUN 代理已经关闭，避免影响公网 80 回包。
