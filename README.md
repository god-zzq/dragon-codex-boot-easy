# Codex 龙娘启动 · 简易版

**下载、解压、双击安装。以后点桌面图标，就能看龙娘动画并进入 Codex。**

这是 [Dragon Codex Boot](https://github.com/yushua0808-cpu/dragon-codex-boot) 的社区改进版。保留上游龙娘视频、实时窗口交接和 MIT 源码，补上实际使用中遇到的启动失败、窗口错位问题，并提供无需改配置的一键安装。

## 三步开始

1. 打开 [最新版本下载页](https://github.com/god-zzq/dragon-codex-boot-easy/releases/latest)，下载 `DragonCodexBootEasy-版本-win-x64-with-video.zip`。
2. **完整解压** ZIP，双击 `Install.cmd`。不要在压缩包预览里直接运行。
3. 安装结束会自动播放。以后双击桌面或开始菜单的 **Codex 龙娘启动（简易版）**。

需要 Windows 10/11 x64、.NET Framework 4.8，并已安装 Windows 版 Codex。无需管理员权限、Node、Python或 API key。Windows N 需要补装媒体功能。

安装器自动识别本机 Codex 应用 ID，把程序复制到 `%LOCALAPPDATA%\DragonCodexBootEasy`，创建当前用户的快捷方式。安装完成后，下载包和解压目录可以删除。已有官方入口继续可用。英文等无法保存中文快捷方式名称的系统自动使用 `Dragon Codex Boot Easy`。

只想试试：解压后直接双击 `Start.cmd` 或 `DragonCodexBoot.exe`，无需安装。便携模式使用随附的标准 Codex 应用标识。

## 使用与卸载

- 动画约 14 秒，带声音；`Esc` 或右上角按钮跳过。跳过后仍继续启动 Codex。
- Codex 已打开时，动画结束交接到现有窗口。
- 卸载：双击解压包里的 `Uninstall.cmd`，或打开 `%LOCALAPPDATA%\DragonCodexBootEasy` 双击同名文件。只移除本工具记录的文件和属于本工具的快捷方式；官方客户端、自定义文件和诊断日志保留。
- 更新：退出动画后，解压新版本，再双击 `Install.cmd`。配置恢复新版本默认值；有自定义配置时先备份 `launcher.json`。
- 调静音：安装目录的 `launcher.json` 中把 `Volume` 改成 `0`，默认 `0.3`。

## 这个版本修了什么

| 实际问题 | 处理方式 |
| --- | --- |
| 动画播放完，Codex 没打开 | 使用 Windows 应用激活接口；失败时回退到系统启动方式，等待期间最多尝试三次 |
| 按跳过后启动中断 | 隐藏动画后继续等待客户端，窗口出现再交接 |
| 页面比动画高，交接时跳变 | 默认 1536×900 物理像素，测量实际客户区；不匹配就重试，并适应客户端的最小尺寸 |
| 解压目录移动后快捷方式失效 | 一键安装复制到固定的用户目录 |
| 用户不懂应用 ID 和配置 | 安装时读取已安装的 Codex 包，自动配置启动入口 |

视频保持原始 16:9 比例，非 16:9 窗口会留边；过渡完成时真实页面填满窗口。窗口尺寸会随屏幕可用区域和客户端尺寸限制调整。客户端在交接时会被调整位置和大小。

默认不扫描磁盘、不替换官方快捷方式。上游的高级入口整合脚本仍保留供手动使用，详见 [入口说明](docs/ENTRYPOINTS.md)。

## 遇到问题

- 找不到 Codex：先用官方入口确认 Windows 版 Codex 已安装，再运行 `Install.cmd`。
- 黑屏或没声音：检查 Windows 媒体功能；仍可按 `Esc` 跳过。
- 对齐异常：日志在安装目录的 `logs/launcher.log`，会记录预期和实际尺寸。提交问题时附系统缩放比例、显示器分辨率和相关日志，先去掉私人信息。
- 下载提示：这是未签名的社区程序，Windows 可能显示来源提示。请从本仓库 Release 下载，并对照随附 SHA-256 文件。

## 从源码构建

在 Windows PowerShell 中运行：

```powershell
./scripts/test.ps1
./scripts/package.ps1
./scripts/verify-repository.ps1
```

输出在 `dist`。GitHub Actions 对提交执行构建、几何/配置测试、快捷方式测试、安装/重装/卸载测试和包校验；`v*` 标签会发布带视频 ZIP 和 SHA-256 文件。

本机已验证真实应用激活、延迟窗口出现时的跳过与重试、完整动画交接和窗口对齐。CI 使用隔离目录测试安装流程，不启动官方客户端。不同显示器和缩放设置仍需实机验证。

## 来源与许可

上游：**[yushua0808-cpu/dragon-codex-boot](https://github.com/yushua0808-cpu/dragon-codex-boot)**。感谢原作者提供龙娘动画、DWM 交接、窗口几何算法、发布包校验和快捷方式恢复机制。

源码按 [MIT](LICENSE) 分发，保留上游版权声明。完整演示视频与原音轨按上游方式随示例分发，保留 [媒体说明](media/MEDIA_NOTICE.md)；源码 MIT 许可不自动授予视频素材的额外用途权利。详见 [第三方说明](THIRD_PARTY_NOTICES.md)。

独立社区项目，与 OpenAI 无隶属关系。

