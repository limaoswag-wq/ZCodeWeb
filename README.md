# ZCodeWeb

电脑 ZCode 官方网页远控的 iPhone 套壳：

- 全屏加载官方 `remote/v4` 页面，界面 100% 官方
- **登录信息持久化**：cookie/localStorage 落盘，重启免登录
- 首次使用：扫码 / 粘贴 `https://zcode.z.ai/remote/v4?...` 链接（保存在本机）
- 无任何通知逻辑；任务通知走电脑端 Bark（见 ZCodeMobile 仓库 `bridge/notify_stop.py`）

## 构建

Codemagic workflow：`zcode-web-unsigned-ipa`，产物 `ZCode.ipa`（巨魔安装）。

```bash
python3 scripts/gen_xcodeproj.py
```
