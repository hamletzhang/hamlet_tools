# hamlet_tools —— AI 编码助手指南

> 本文档面向不了解本项目的 AI 编码助手。所有信息均基于项目实际内容，不做假设。

---

## 项目概述

`hamlet_tools` 是 [hamletzhang](https://github.com/hamletzhang/hamlet_tools) 维护的个人小工具集仓库，通过 **GitHub Pages** 对外提供纯静态页面。项目不包含后端服务、构建工具或包管理器，所有功能均为单文件或少量文件组成的前端 HTML/CSS/JS 应用。

仓库地址：`https://github.com/hamletzhang/hamlet_tools.git`

当前分支：`master`（注意：GitHub Actions 部署工作流配置为监听 `main` 分支推送，若实际默认分支为 `master`，则自动部署不会触发，需手动确认或修正工作流。）

### 目录结构

```
hamlet_tools/
├── .github/workflows/static.yml   # GitHub Pages 部署工作流
├── README.md                       # 项目简介（中文）
├── games/                          # 浏览器小游戏
│   ├── ddz.html                    # 赛博朋克风格斗地主（人机对战）
│   └── 明熹宗-泰昌九月可玩原型.html  # 明朝历史叙事选择类游戏
└── tools/                          # 实用工具
    ├── dlcv_cam_viewer.html        # RK 智能相机监控看板
    └── lofi-radio/                 # Lofi 电台播放器
        ├── index.html
        ├── css/style.css
        └── js/script.js
```

---

## 技术栈与运行时架构

- **纯静态前端**：无构建步骤、无框架、无 Node.js / Python / Rust 等运行时依赖。
- **技术组合**：原生 HTML5 + CSS3 + Vanilla JavaScript。
- **外部依赖**：均通过 CDN 引入，无本地 `node_modules`：
  - [Tailwind CSS](https://cdn.tailwindcss.com)（`dlcv_cam_viewer.html`）
  - [Chart.js](https://cdn.jsdelivr.net/npm/chart.js)（`dlcv_cam_viewer.html`）
  - [Font Awesome](https://cdnjs.cloudflare.com/ajax/libs/font-awesome/)（`dlcv_cam_viewer.html`、`lofi-radio`）
  - [Google Fonts](https://fonts.googleapis.com)（`lofi-radio`）
  - [Bilibili 播放器 iframe](https://player.bilibili.com)（`lofi-radio`）
- **部署方式**：GitHub Actions → GitHub Pages（`actions/deploy-pages@v4`）。

---

## 各模块详细说明

### 1. `games/ddz.html` —— 斗地主（人机对战）

- **单文件应用**：所有 HTML、CSS、JavaScript 写在一个文件内。
- **玩法**：玩家（人类） vs 两个 AI 对手，完整包含叫分、抢地主、出牌流程。
- **代码组织**：
  - `Card` 类：定义扑克牌属性（花色、点数、ID、选中状态）。
  - `Rule` 对象：极简牌型规则引擎，支持单张、对子、三张、三带一、三带二、顺子、炸弹、火箭。
  - `Game` 类：核心状态机（`IDLE` → `BIDDING` → `SNATCHING` → `PLAYING` → `OVER`），管理发牌、回合循环、胜负判定。
  - `UI` 类：负责 DOM 渲染、按钮生成、动画特效（赛博朋克风格：霓虹蓝/粉/金配色、透视网格背景、 clip-path 按钮）。
- **关键设计**：人类回合时通过 `return` 强制中断 `loop()`，等待 UI 回调（按钮点击）后继续，避免异步阻塞。
- **AI 策略**：极简随机策略，仅处理最小单张与简单管牌逻辑。

### 2. `games/明熹宗-泰昌九月可玩原型.html` —— 明朝叙事策略原型

- **类型**：轻策略 + 强叙事的纯文字选择游戏。
- **背景**：玩家扮演明熹宗朱由校，处理泰昌元年九月的六大政治事件（移宫案、红丸案、首辅去留、辽饷、辽东主帅等）。
- **代码组织**：
  - `statConfig`：六项朝局数值定义（皇权、外廷支持、内廷依赖、财政压力、辽东军务压力、朝局稳定），含正向/危险类型标记。
  - `events[]`：六个事件的数据驱动配置，每个事件包含史实锚点、戏剧补白、多个选项及效果。
  - `state` 对象：维护当前阶段、事件索引、数值、隐藏 flags、历史记录。
  - 渲染函数：`renderIntro()` → `renderOverview()` → `renderEvent()` → `renderResult()` → `renderEnding()`。
  - `resolveEnding()`：根据最终数值与 flags 判定结局（危局四伏 / 众正盈朝 / 深宫暗线 / 勉强持衡 / 疑心已生）。
- **设计特点**：每个选项均标注史实锚点与戏剧化处理，明确区分真实史料与玩法演绎。

### 3. `tools/dlcv_cam_viewer.html` —— RK 设备监控看板

- **用途**：为 dlcv 智能相机提供实时监控的简易网页。
- **功能**：
  - 通过用户指定的 REST API（默认 `http://192.168.1.29:8000/api/system/monitor/info`）轮询系统数据。
  - 展示 CPU 使用率、CPU 频率、NPU 频率等关键指标。
  - 使用 Chart.js 绘制 CPU 负载趋势图（30 秒滑动窗口）与 NPU 双核负载图。
  - 提供原始 JSON 调试视图。
- **架构**：单页应用，页面加载后自动调用 `toggleMonitoring()` 开始每秒轮询。
- **注意**：依赖目标设备提供跨域（CORS）支持，请求超时设为 2 秒。

### 4. `tools/lofi-radio/` —— Lofi 电台播放器

- **用途**：以 Bilibili 视频为音源的 Lofi 氛围音乐播放器，适合工作学习背景音。
- **文件拆分**：`index.html` + `css/style.css` + `js/script.js`（本项目中最接近"模块化"的结构）。
- **功能**：
  - 嵌入 Bilibili 播放器 iframe。
  - 三套可切换主题：
    - **太空赫兹电台**（默认）：深蓝星空、卫星、行星、宇航员 CSS 动画。
    - **深夜最后一班公交车**：雨夜街道氛围，偏冷灰蓝调。
    - **打烊后的酒吧**：暖黄/橙红色调，酒吧氛围。
  - 播放/暂停、音量增减按钮（通过 `postMessage` 向 Bilibili iframe 发送控制指令）。
  - 模拟控制台终端，周期性输出与当前主题匹配的氛围日志。
  - 随机生成的 CSS 星空、流星、无线电波扩散动画。
- **主题切换**：修改 `body` class 并同步更新标题、副标题、iframe 视频源、控制台消息库。

---

## 构建与测试

### 构建

**无需构建**。本项目没有 `package.json`、`vite.config.js`、`webpack.config.js` 或任何构建脚本。文件直接以静态资源形式通过浏览器打开即可运行。

### 本地预览

最简单的方式：

```bash
# 方式一：直接用浏览器打开文件
start games/ddz.html
start tools/lofi-radio/index.html

# 方式二：使用任意静态文件服务器（如 Python、Node npx serve 等）
# 在项目根目录执行：
python -m http.server 8080
# 然后访问 http://localhost:8080/games/ddz.html
```

### 测试

**无自动化测试框架**（无 Jest、Vitest、Playwright 等）。所有测试均为手动浏览器验证：

1. 打开目标 HTML 文件。
2. 检查控制台（Console）无报错。
3. 验证核心交互路径（如出牌、主题切换、API 数据刷新）。
4. 检查响应式布局（部分页面有 `@media` 断点）。

---

## 代码风格指南

### 语言

- **所有代码注释、UI 文案、文档均为中文**。新增功能请保持中文注释与界面文案。

### HTML/CSS

- 单文件应用倾向于将 `<style>` 写在 `<head>` 中，`<script>` 写在 `</body>` 之前。
- CSS 变量（`:root`）广泛用于主题色管理（如 `--neon-blue`、`--gold`）。
- 使用 `grid` / `flex` 布局为主，配合 `clamp()` 实现响应式字体。

### JavaScript

- **ES6+ 语法**：使用 `const`/`let`、箭头函数、`class`、`template literals`。
- **无 TypeScript**：纯 JS，无类型注解。
- **状态管理**：简单对象或类实例（如 `Game`、`UI`）维护全局状态，无 Redux/Vuex 等状态库。
- **DOM 操作**：原生 `document.getElementById` / `document.querySelector` + `innerHTML` 拼接字符串为主。
- **无模块化**：不使用 `import`/`export`（`lofi-radio` 除外，它按文件拆分但仍通过全局 `<script>` 标签加载）。

---

## 部署流程

部署由 `.github/workflows/static.yml` 自动完成：

1. **触发条件**：
   - `push` 到 `main` 分支（⚠️ 当前仓库默认分支为 `master`，工作流可能不会被自动触发）。
   - 手动 `workflow_dispatch`。

2. **步骤**：
   - `actions/checkout@v4` 检出代码。
   - `actions/configure-pages@v5` 配置 Pages。
   - `actions/upload-pages-artifact@v3` 上传整个仓库根目录作为部署产物。
   - `actions/deploy-pages@v4` 部署到 GitHub Pages。

3. **环境**：`github-pages`，部署 URL 由 `steps.deployment.outputs.page_url` 输出。

> **维护提示**：若默认分支为 `master` 而工作流监听 `main`，请统一分支名称，或修改 `static.yml` 中的 `branches` 列表。

---

## 安全注意事项

1. **CORS 依赖**：`dlcv_cam_viewer.html` 需要目标设备 API 允许跨域访问，否则浏览器会拦截 `fetch` 请求。
2. **外部 CDN**：项目依赖多个第三方 CDN（Tailwind、Chart.js、Font Awesome、Bilibili）。若这些服务不可用或内容被篡改，页面功能将受影响。对于高安全场景，建议将关键资源本地化。
3. **无输入校验**：`dlcv_cam_viewer.html` 的 API URL 输入框未做严格 URL 格式校验，用户可能输入任意地址。
4. **无 HTTPS 强制**：GitHub Pages 默认支持 HTTPS，但 `dlcv_cam_viewer.html` 默认指向 `http://192.168.1.29:8000`（内网 HTTP），在现代浏览器的 HTTPS 页面中混合访问 HTTP 资源可能被阻止。
5. **XSS 风险**：部分页面使用 `innerHTML` 拼接动态内容（如控制台消息、历史记录），若未来引入用户输入数据源，需做转义处理。当前纯静态数据，风险较低。

---

## 开发建议

- **新增工具/游戏**：建议在 `tools/` 或 `games/` 下新建目录或单 HTML 文件，保持与现有风格一致。
- **修改现有页面**：优先在对应单文件内修改；`lofi-radio` 如需调整样式或交互，分别编辑 `css/style.css` 与 `js/script.js`。
- **Git 操作**：每次修改后推送到远程即可触发（或手动触发）GitHub Pages 重新部署。
- **无需引入构建链**：本项目定位为轻量静态页面集合，引入 Webpack/Vite 等反而增加维护负担。如需新依赖，优先考虑 CDN 方式引入。
