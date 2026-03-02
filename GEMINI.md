# Wallhaven iOS App - AI Context & Operation Manual

## 📌 项目概述 (Project Overview)
- **项目名称**: Wallhaven iOS App
- **代码仓库**: [shinelee2014/wallhaven-ios-app](https://github.com/shinelee2014/wallhaven-ios-app)
- **项目目标**: 为 Wallhaven.cc 构建一个高级、深色系、具有玻璃拟态设计风格的 iOS 客户端。
- **发布目标**: 内部企业分发（Enterprise Distribution）。通过云端 CI/CD 绕过签名校验，生成无签名 IPA，再由用户在本地使用企业证书重签安装。

## 🛠 技术栈 (Tech Stack)
- **框架**: Flutter (Stable Channel)
- **网络请求**: `dio` (与 Wallhaven v1 API 交互)
- **图片加载与缓存**: `cached_network_image`
- **状态管理**: `provider`
- **UI 布局**: `flutter_staggered_grid_view` (实现瀑布流展示)
- **CI/CD**: GitHub Actions (云端编译并打包 `.ipa`)

## 🏗 架构与目录结构 (Architecture & Structure)
遵循标准的 Flutter 架构：
- `lib/models/`: 数据模型 (如 `wallpaper.dart`)
- `lib/services/`: API 服务层 (如 `wallhaven_service.dart`)
- `lib/providers/`: 状态管理层 (如 `wallpaper_provider.dart`)
- `lib/views/`: 页面视图 (如 `home_view.dart`, `detail_view.dart`)
- `lib/widgets/`: 可复用 UI 组件
- `ios/`: iOS 平台特定代码。**注：我们故意排除了大部分 iOS 样板文件，使其由 CI/CD 在云端动态生成，以保证环境干净。**

## 🚀 核心工作流与 CI/CD 机制 (Core Workflows & CI/CD)
**【核心警告】：这是本项目的难点和特色机制，后续开发切勿随意修改。**
由于在云端 (GitHub Actions) 构建无需签名的 iOS Flutter 应用时，Flutter 编译链和 Xcode 仍会强制校验 `DEVELOPMENT_TEAM` 甚至报错，我们采取了以下“硬核”截断策略：

### 1. 签名强制绕过逻辑 (Signing Bypass)
- **云端生成模版**: 工作流首先执行 `flutter create --platforms=ios .` 补全缺失的 iOS 配置文件。
- **xcconfig 注入**: 项目中包含一个特殊的配置文件 `ios/FlashSigning.xcconfig`，强制覆盖了签名设置：
  ```xcconfig
  DEVELOPMENT_TEAM = DUMMY12345
  CODE_SIGN_STYLE = Manual
  CODE_SIGN_IDENTITY = 
  CODE_SIGNING_REQUIRED = NO
  CODE_SIGNING_ALLOWED = NO
  PROVISIONING_PROFILE_SPECIFIER = 
  PROVISIONING_PROFILE = 
  ```
- **配置覆盖**: 工作流通过 `cat ios/FlashSigning.xcconfig >> ios/Flutter/Release.xcconfig` 将上述规则强行注入到 Flutter 的 Release 配置末尾，压制报错。
- **构建命令**: 最后使用 `flutter build ios --release --no-codesign` 进行纯净编译。

### 2. 构建与部署流程 (`.github/workflows/build_ipa.yml`)
- **触发条件**: 任何对 `master` 分支的 Push 操作。
- **输出产物**: 构建成功后，在 GitHub Actions 运行记录页生成名为 `wallhaven-unsigned-ipa` 的 Artifact（zip 格式，解压后即为 `.ipa`）。
- **用户自提**: AI 会通知用户手动下载此 IPA，并自行使用企业签工具完成最终部署。

## 🎨 UI/UX 设计规范 (Design Guidelines)
- **色彩空间**: 深色系 (Dark Mode)，背景以极深灰色渐变或纯黑为主，凸显壁纸的鲜艳色彩。
- **高级感元素**:
  - 大量使用具有半透明、毛玻璃效果的**玻璃拟态** (Glassmorphism) 组件（如 AppBar, 底部操作栏/BottomSheet）。
  - 壁纸展示采用**瀑布流 (Masonry Grid)**，边缘应用平滑的相框圆角 (`BorderRadius`)。
  - Subtle glow (微妙发光) 或细腻的点击反馈效果提升交互感。
- **交互哲学**: 极简至上。保留核心的“最新(Latest)”、“排榜(Toplist)”、“随机(Random)”切换，隐藏繁杂设置。

## 📝 待办事项与后续开发 (TODOs for Next Sessions)
1. **API Key 赋能**: 当前 API 请求是未授权的。需在 `wallhaven_service.dart` 中对接用户的 API Key，以解锁 NSFW (成人/敏感) 分级图片及获取用户的私人 Collections。
2. **过滤与排序面板**: 完善 `HomeView` 中因时间原因简化掉的 BottomSheet 过滤面板，让用户能精细化筛选 Purity (SFW/Sketchy/NSFW) 和 Categories (General/Anime/People)。
3. **无缝翻页加载**: 瀑布流尚未实现到底部的自动无限加载 (Infinite Scrolling) 功能，需在 Provider 中增加分页逻辑。
4. **性能监控与大图优化**: 壁纸原图通常几 MB 到十几 MB，需监控 `cached_network_image` 的内存占用，避免 OOM 崩溃。

## 🤖 助手操作规程 (Operational Manual for AI)
1. **首要原则**: 在新的对话中读取到本文件后，必须**完全继承**上述的设计审美和架构决定。
2. **勿动核心构建链**: 绝对不要出于“修复警告”的目的随意修改 `build_ipa.yml` 或 `FlashSigning.xcconfig` 中的绕过逻辑，这经历了数十次实验才稳定下来。
3. **保持同步**: 完成重要 Feature 后，及时执行 `git commit` 以及 `git push origin master`，触发 GitHub 自动构建。
4. **状态更新**: 如果项目的架构方向或核心配置发生了重大变动，请记得更新此 `GEMINI.md` 文档。
