# 星际守卫者 (Star Defender)

## 项目简介

这是一个使用 **Godot 4.6.3-stable** 开发的 2D 俯视角飞机射击游戏 Demo。

本项目的主要目的：
1. **验证 Godot 引擎功能**：节点-场景系统、信号机制、物理碰撞、粒子特效
2. **验证 AI 辅助游戏开发流程**：从架构设计到代码实现，展示 AI 如何加速游戏开发
3. **作为教学案例**：配套 `godot-guide` 网站，提供完整的设计思路、架构解析和代码讲解

## 技术栈

- **引擎**: Godot 4.6.3-stable
- **语言**: GDScript 2.0（渐进式类型系统）
- **渲染**: Mobile 渲染后端（兼容 WebGL2）
- **美术**: 程序生成几何图形（Polygon2D），零外部美术资源依赖

## 游戏特性

### 核心玩法
- WASD / 方向键 控制飞机移动
- 空格键 或 自动射击
- ESC 键 暂停/恢复

### 敌人 AI 系统（3种敌人类型）
| 敌人类型 | 外观 | AI 行为 | 血量 | 分数 |
|---------|------|---------|------|------|
| 基础敌人 | 红色三角形 | 正弦波摆动 + 直线下降 | 1 | 100 |
| 快速敌人 | 黄色菱形 | 高速下降 + 追踪玩家 X 轴 | 1 | 200 |
| 坦克敌人 | 绿色方块 | 慢速直线 + 3连发散弹 | 5 | 500 |

### 关卡波次系统
- 10 个预设波次，程序化生成敌人配置
- 波次完成后循环并增加难度（强度乘数）
- 数据驱动配置，易于 AI 辅助修改和扩展

### 其他特性
- 无敌帧 + 闪烁效果（受伤后 2 秒无敌）
- 摄像机震动反馈
- 爆炸粒子特效
- 分数评级系统

## 项目结构

```
godot-shooter/
├── project.godot          # 项目配置（含输入映射、碰撞层、AutoLoad）
├── icon.svg               # 项目图标
├── scenes/                # 场景文件（节点树配置）
│   ├── main.tscn          # 主游戏场景
│   ├── player.tscn        # 玩家飞机（HurtBox 碰撞检测架构）
│   ├── player_bullet.tscn # 玩家子弹
│   ├── enemy_basic.tscn   # 基础敌人
│   ├── enemy_fast.tscn    # 快速敌人
│   ├── enemy_tank.tscn    # 坦克敌人
│   ├── enemy_bullet.tscn  # 敌人子弹
│   ├── explosion.tscn     # 爆炸粒子特效
│   └── ui/
│       ├── hud.tscn       # 游戏内 HUD
│       ├── main_menu.tscn # 主菜单
│       └── game_over.tscn # 游戏结束画面
└── scripts/               # GDScript 脚本
    ├── game_manager.gd    # 全局状态单例（AutoLoad）
    ├── main.gd            # 主场景"导演"逻辑
    ├── player.gd          # 玩家控制 + HurtBox 碰撞
    ├── player_bullet.gd   # 玩家子弹
    ├── enemy_base.gd      # 敌人抽象基类
    ├── enemy_basic.gd     # 基础敌人 AI
    ├── enemy_fast.gd      # 快速敌人 AI（追踪玩家）
    ├── enemy_tank.gd      # 坦克敌人 AI（3连发）
    ├── enemy_bullet.gd    # 敌人子弹
    ├── explosion.gd       # 爆炸特效
    ├── wave_manager.gd    # 波次管理器（数据驱动）
    ├── camera_shake.gd    # 摄像机震动
    ├── star_field.gd      # 程序化滚动星空背景
    ├── hud.gd             # HUD 更新（分数/血量/波次/剩余敌人）
    ├── main_menu.gd       # 主菜单
    └── game_over.gd       # 游戏结束
```

## 开发规范

本项目遵循以下开发规范（所有代码文件顶部均有注释说明）：

1. **GDScript 2.0 渐进式类型**：关键变量显式标注类型，提升性能和可读性
2. **@onready 懒加载**：所有节点引用使用 `@onready` 延迟初始化
3. **@export 暴露配置**：可调整参数使用 `@export` 暴露到 Inspector
4. **信号命名规范**：使用过去式（如 `health_changed`, `wave_completed`）
5. **命名规范**：类名 PascalCase，变量/函数 snake_case，常量 UPPER_SNAKE_CASE，私有成员前缀 `_`
6. **中文注释**：所有注释使用中文，方便国内开发者阅读
7. **继承定义类型 + 组合拆分职责**：继承用于类型层次（`EnemyBase` → enemy_basic/fast/tank，子类覆盖 `_update_ai()`）；组合用于职责拆分（玩家的 HurtBox / Muzzle / 各 Timer 都是独立子节点）。按场景取舍，而非笼统"组合优于继承"
8. **信号统一在代码中连接**：碰撞等信号一律在脚本 `_ready()` 里 `connect`，不在 `.tscn` 中连，避免"场景连一次、代码再连一次"的双重连接
9. **单一伤害裁决者**：玩家是否受伤只由 Player 的 HurtBox 判定（含无敌帧）；子弹只负责自毁，不自行扣血，避免无敌帧被绕过与双重扣血
10. **全局状态单例**：使用 AutoLoad 单例（`GameManager`）管理游戏状态与信号总线，避免节点间硬引用

## 如何运行

### 方法 1：Godot 编辑器（推荐）
1. 下载并安装 [Godot 4.6.3-stable](https://godotengine.org/download/)
2. 打开 Godot 编辑器，点击"导入"，选择本项目的 `project.godot` 文件
3. 按 F5 或点击"运行项目"按钮

### 方法 2：命令行
```bash
# 运行项目
Godot_v4.6.3-stable_win64_console.exe --path /path/to/godot-shooter

# 仅验证脚本（无报错即成功）
Godot_v4.6.3-stable_win64_console.exe --path /path/to/godot-shooter --headless --quit
```

### 方法 3：导出后运行
1. 在 Godot 编辑器中：`项目 > 导出`
2. 添加导出预设（Windows / macOS / Linux / Web）
3. 点击"导出项目"

> **验证与修复记录（AI 辅助流程的"分层验证"环节）**：初版代码通过菜单静置检查，但真正进入战斗循环后用 headless 自动开局跑帧 + 渲染截帧验证，暴露并修复了以下问题：
> - 信号双重连接（`.tscn` 连一次 + 脚本 `_ready` 又 connect 一次）→ "Signal already connected" 报错刷屏。统一改为只在代码连接。
> - 空格手动射击在 `project.godot` 中定义了 `shoot` 动作，但 `player.gd` 从未读取 → 已在 `_input` 中补齐（与自动射击并存）。
> - 敌人子弹绕过玩家无敌帧直接扣血、且与 HurtBox 重复扣血 → 改为子弹只自毁，伤害由 HurtBox 单一裁决。
> - 暂停时 `await get_tree().create_timer()` 默认不受暂停影响 → 第二参数传 `false` 使其暂停感知，避免暂停态生成敌人/重生。
> - `wave_manager.gd` 取视口尺寸改用 `get_viewport().get_visible_rect().size`（视口逻辑坐标），而非窗口像素尺寸。
> - HUD 的"剩余敌人"标签此前为静态死值 → 接入 `GameManager.enemy_count_changed` 信号实时更新。
> - 删除未被任何脚本继承的死代码 `bullet_base.gd`；新增程序化滚动星空 `star_field.gd`。

## 控制说明

| 按键 | 功能 |
|------|------|
| W / ↑ | 向上移动 |
| S / ↓ | 向下移动 |
| A / ← | 向左移动 |
| D / → | 向右移动 |
| 空格 | 手动射击（与自动射击并存） |
| ESC | 暂停 / 恢复 |

## 配套教程

本项目配套详细教程网站：
**https://hamletzhang.github.io/hamlet_tools/tools/godot-guide/index.html**

教程涵盖：
- Godot 引擎介绍与安装
- GDScript / C# / C++ 开发语言详解
- 节点-场景架构深度解析
- **AI 辅助游戏开发**（重点）：工具推荐、代码生成、LLM 集成、最佳实践

## 许可证

本项目采用 MIT 许可证，与 Godot 引擎一致。

---

> 本项目是 AI 辅助游戏开发的验证案例。从架构设计到代码实现，AI 工具在以下环节提供了辅助：
> - 架构设计与代码结构规划
> - GDScript 代码生成与优化
> - 关卡波次配置的 JSON 化设计
> - 碰撞检测架构的迭代优化
