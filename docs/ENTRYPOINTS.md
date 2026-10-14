# 安装与启动入口

简易版推荐双击 Release 中的 `Install.cmd`，自动检测 Codex 并安装到 `%LOCALAPPDATA%\DragonCodexBootEasy`。

只创建当前用户桌面和开始菜单中的「Codex 龙娘启动（简易版）」。不修改官方快捷方式，不扫描磁盘。同名快捷方式若指向其他程序，会保留并报告冲突。

重复安装用于更新，使用新版默认配置。卸载使用 `Uninstall.cmd`，根据安装清单移除自身文件；被用户改成其他目标的快捷方式保留。日志和自定义文件保留，官方 Codex 不受影响。

## 上游高级工具

`Rescan-Entrypoints.cmd` 和 `scripts/integrate-entrypoints.ps1` 是保留的上游高级入口整合工具，只有手动执行才会运行。
它们会查找并替换符合配置的官方 `.lnk`，修改前备份，报告放在 `.integration/report.json`。如果使用了这些工具，删除安装目录前先执行 `Restore-Original-Entrypoints.cmd`。

简易安装和卸载不管理手动执行的高级整合记录。推荐使用单独的新入口，避免混用。
