## 0.3.5

- Always play the full animation. Remove the automatic jump triggered by window responsiveness.

## 0.3.4

- Replace the drawn avatar with a face crop from the bundled dragon-girl animation, with rounded corners and seven icon sizes.
- The portrait is derived from startup.mp4 and retains that media's rights notice.

## 0.3.3

- Bundle an original purple dragon-girl icon and allow only its two named public assets in repository verification.

## 0.3.2

- Always activate Codex through Windows application identity; avoid direct MSIX executable launch and profile separation.
- Exclude processes without the configured application package identity from window handoff.
- Include Repair-Startup.cmd to restart an existing unpackaged instance without clearing user data.
- FastStart shortens animation when a matching responsive window appears. Window checks do not confirm page readiness.

# Changelog

## 0.2.0 — 2026-10-06

- 默认首次运行在后台替换可识别的官方客户端启动快捷方式，扫描常用入口和可访问的本地固定磁盘。
- 保留快捷方式名称和图标，通过真实目标和精确 AppsFolder ID 匹配，避免误改同名程序及网页。
- 每个改动保存原文件和校验和，附带一键恢复、重新扫描及逐项报告；保留安装后用户的改动。
- 明确记录权限、扫描预算、应用注册入口及固定缓存的限制。
- 新增隔离快捷方式回归测试，发布包默认包含功能脚本和原1080p视频。

## 0.1.0 — 2026-10-06

- 从私人龙娘启动动画项目整理出独立 Windows C# WPF 启动器。
- 固定物理像素播放、等待节点、DWM 实时界面过渡及 Esc 跳过。
- 配置输入校验、离线几何测试和 Windows 构建工作流。
- 视频导入、可撤销的快捷方式安装和干净的程序打包。
- MIT 软件许可证，以及单独的随附媒体说明。
- 包含完整1080p龙娘启动动画，默认程序包解压即可运行。
