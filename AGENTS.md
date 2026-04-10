# AGENTS.md

请始终使用简体中文与用户沟通。
代码、命令、路径、报错信息可保留原文；解释、说明、总结必须使用中文。
除非用户明确要求，否则不要切换为英文回复。

## Project Context

- 这是一个已有基础闭环的 Godot 4 项目。
- 当前已知关键信息：
  - `project.godot` 中主场景是 `res://scenes/MainMenu.tscn`
  - 已存在 autoload：`GameState="*res://scripts/GameState.gd"`
  - 主要场景位于 `scenes/`
  - UI 场景位于 `ui/`
  - 核心脚本位于 `scripts/`
- 当前项目已经存在这些脚本职责分层：
  - `BattleController.gd`
  - `WaveDirector.gd`
  - `UpgradeManager.gd`
  - `UpgradeOverlay.gd`
  - `HUD.gd`
  - `ResultScreen.gd`
  - `Player.gd`
  - `Enemy.gd`
  - `Projectile.gd`
  - `GameState.gd`
- 后续开发应优先延续这套分层，不要把逻辑重新堆回单个“大脚本”里。

## Shell Preference

- 默认优先使用 Git Bash 执行命令。
- 如果 Git Bash 不方便、不兼容，或命令只适合 Windows 原生命令行，再使用 cmd。
- 除非明确必要，否则不要使用 PowerShell。
- 如果任务需要管理员权限，优先使用管理员模式的 cmd，而不是 PowerShell。
- 面向用户提供命令时，默认优先给出 Git Bash 写法；仅在必须时再补充 cmd 写法。
- 执行命令时，优先采用：
  - `bash -lc "<command>"`
  - `cmd /c <command>`

## Godot Workflow

- 先检查相关场景、对应脚本和 `project.godot`，再开始修改。
- 新功能优先落到现有职责里：
  - 战斗流程优先看 `BattleController.gd`
  - 波次逻辑优先看 `WaveDirector.gd`
  - 升级流程优先看 `UpgradeManager.gd` / `UpgradeOverlay.gd`
  - 全局状态优先看 `GameState.gd`
  - UI 显示优先看 `HUD.gd` / `ResultScreen.gd`
- 不要把波次、升级、HUD、结果页逻辑混写在 `Player.gd` 或单个场景控制脚本里。
- 修改场景节点时，要同步检查脚本绑定、导出变量和信号连接。
- 如果新增输入操作，先检查 `project.godot` 中已有输入映射，再做最小必要补充。

## Coding Workflow

- 优先做最小必要改动，避免无关重构。
- 不要擅自删除用户已有场景、脚本、资源或配置。
- 如果已有结构能承接需求，就优先扩展现有脚本，而不是重起一套平行体系。
- 保持战斗逻辑、UI 逻辑、升级逻辑、全局状态分离。
- 如果要重构职责边界，先说明原因和收益。

## Godot Verification

- 修改完成后，尽量做可运行验证，而不是只改文件不验证。
- 优先检查这些闭环是否仍然成立：
  - 主菜单进入战斗
  - 波次推进
  - 升级选择
  - HUD 正常刷新
  - 结果页正常展示
  - 返回主菜单或重新开始流程不报错
- 如果有 `SmokeTest.gd` 或类似测试入口，优先考虑复用。
- 如果当前环境缺少 Godot 可执行文件，或无法启动项目，要明确说明原因。

## project.godot / Autoload Safety

- 不要随意改动 `run/main_scene`，除非任务明确要求更换主入口。
- 不要随意删除或替换 `GameState` autoload。
- 新增 autoload、输入映射、窗口配置时，要说明具体目的和影响。
- 除非确有必要，否则不要直接大范围手改 `project.godot`。

## Git Workflow

- 不要使用破坏性 Git 命令，例如：
  - `git reset --hard`
  - `git checkout -- <file>`
  - `git clean -fd`
- 除非用户明确要求，否则不要改写历史，不要强推。
- 提交前先确认本次改动范围。
- 提交信息尽量简洁清晰，说明改动目的。

## Output Preference

- 回复尽量简洁、直接、可执行。
- 先说结论，再补必要说明。
- 如果是功能开发，优先说明：
  - 改了哪些系统
  - 当前一局完整流程怎么跑
  - 还有哪些明显缺口
  - 下一步最值得补什么

## Safety

- 不要执行用户未明确同意的高风险操作。
- 涉及删除、覆盖、移动大量资源文件时，先确认目标路径和影响范围。
- 涉及 `project.godot`、autoload、主场景、输入映射调整时，先说明将要做什么。
