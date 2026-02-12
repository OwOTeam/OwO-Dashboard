# OwO! Dashboard

一个现代化的 Flutter 跨平台应用框架，专为桌面端（Windows）和移动端设计。采用**高度模块化**架构，支持插件式功能扩展。

[![Flutter](https://img.shields.io/badge/Flutter-%5E3.9.2-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Author-HanskiJay-orange.svg)](https://github.com/Tommy131)

---

## 📋 目录

- [系统架构](#系统架构)
- [核心特性](#-核心特性)
- [快速开始](#-快速开始)
- [模块化开发指南](#-模块化开发指南)
- [核心 API 说明](#️-核心-api-说明)
- [版权与许可证](#-版权与许可证)

---

## 系统架构

本项目采用 **组件化、模块化、插件化** 的三层架构设计：

```tree
┌─────────────────────────────────────────────────────────────┐
│                      应用层 (Application)                    │
│  ┌────────────┐  ┌────────────┐  ┌─────────────┐            │
│  │ MyApp      │  │ MainScreen │  │ SetupWizard │            │
│  └────────────┘  └────────────┘  └─────────────┘            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   模块注册层 (Module Registry)               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ ModulesRegisterEntry (统一注册入口)                   │   │
│  │  ├─ ExampleModule                                    │   │
│  │  ├─ YourCustomModule                                 │   │
│  │  └─ ...                                              │   │
│  └──────────────────────────────────────────────────────┘   │
│                            ↓                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ ModuleRegistry (核心注册表管理器)                     │   │
│  │  ├─ NavigationRegistry      (导航项)                 │   │
│  │  ├─ AppBarActionRegistry    (顶栏按钮)               │   │
│  │  ├─ SidebarFooterRegistry   (侧边栏底部组件)         │    │
│  │  ├─ WizardStepRegistry      (引导步骤)               │   │
│  │  ├─ SettingsPageRegistry    (设置页面)               │   │
│  │  └─ CleanupCallbacks        (清理回调)               │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    核心框架层 (Core Framework)               │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐             │
│  │ Services   │  │ Layouts    │  │ Theme      │             │
│  │ Widgets    │  │ Utils      │  │ i18n       │             │
│  │ Update     │  │            │  │            │             │
│  └────────────┘  └────────────┘  └────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

### 核心目录结构

```tree
lib/
├── core/                          # 核心框架层
│   ├── app.dart                   # 应用入口与主屏幕
│   ├── constants/                 # 全局常量（版本号、URL等）
│   ├── module_registry/           # 模块注册中心 ⭐
│   │   ├── module_registry.dart   # 核心注册表管理器
│   │   ├── module_registrar.dart  # 模块接口定义
│   │   ├── navigation/            # 导航项注册
│   │   ├── app_bar/               # 顶栏按钮注册
│   │   ├── sidebar/               # 侧边栏组件注册
│   │   ├── settings_page/         # 设置页面注册
│   │   └── update/                # 更新检测配置
│   │       └── update_config.dart # 更新配置
│   ├── setup_wizard/              # 引导程序框架
│   ├── settings_pages/            # 设置页面框架
│   ├── services/                  # 全局服务
│   │   ├── persistence_service.dart    # 持久化存储
│   │   ├── localization_service.dart   # 国际化服务
│   │   ├── notification_service.dart   # 通知服务
│   │   ├── update_service.dart         # 更新检测服务
│   │   ├── bootstrap_service.dart      # 引导配置
│   │   └── font_service.dart           # 字体管理
│   ├── layouts/                   # 响应式布局
│   ├── theme/                     # Material 3 主题
│   ├── localization/              # 国际化资源
│   ├── widgets/                   # 通用组件库
│   └── utils/                     # 工具类
│       └── update_checker.dart    # 更新检测 UI 辅助
│
├── modules/                       # 业务模块层 ⭐
│   ├── modules_register_entry.dart  # 模块集中注册入口
│   └── example_module/            # 示例模块
│       ├── example_module.dart    # 模块注册实现
│       ├── pages/                 # 页面组件
│       ├── wizard/                # 引导步骤
│       └── localization/          # 模块专属国际化
│
└── main.dart                      # Flutter 入口
```

---

## ✨ 核心特性

### 1. **插件化模块系统**

- ✅ 所有功能通过 `ModuleRegistrar` 接口注册，无需修改核心代码
- ✅ 支持动态加载导航页面、设置页面、引导步骤、顶栏按钮等
- ✅ 模块间完全解耦，可独立开发、测试、部署

### 2. **完整的国际化支持**

- ✅ 核心框架与业务模块分离的多语言管理
- ✅ 支持动态语言切换，所有 UI 实时响应
- ✅ 内置中文（简体）、英文支持
- ✅ 模块可单独注册翻译包并使用命名空间隔离

### 3. **响应式布局**

- ✅ 桌面端/移动端自动适配
- ✅ 侧边栏可折叠，支持展开/收起状态
- ✅ 自定义标题栏（Windows）

### 4. **强大的引导系统**

- ✅ 首次启动自动进入引导流程
- ✅ 支持多步骤配置，优先级排序
- ✅ 配置摘要自动生成

### 5. **灵活的设置系统**

- ✅ 多级设置菜单，支持动态扩展
- ✅ 主题切换、语言切换、存储路径管理
- ✅ 关于页面自动集成版本信息

### 6. **内置更新检测模块**

- ✅ 支持自动检测与手动检测
- ✅ 统一的更新配置入口与版本对话框

---

## 🚀 快速开始

### 环境要求

- **Flutter SDK**: ^3.9.2
- **Dart SDK**: ^3.0.0
- **支持平台**: Windows (主要), Android, iOS

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
# 开发模式
flutter run

# Windows 发布版本
flutter build windows --release
```

---

## 🧩 模块化开发指南

### 模块注册流程

所有业务模块通过 `modules/modules_register_entry.dart` 统一注册，并在应用初始化时触发：

```dart
// lib/modules/modules_register_entry.dart
class ModulesRegisterEntry {
  static void registerAll() {
    final registry = ModuleRegistry();

    // 1. 注册所有业务模块
    registry.registerModule(ExampleModule());
    registry.registerModule(YourCustomModule());  // 添加你的模块

    // 2. 初始化所有模块
    registry.initializeAll();

    // 3. 注册全局清理回调（可选）
    _registerGlobalCleanup(registry);
  }
}
```

应用启动入口会调用统一注册入口（`lib/core/app.dart`）：

```dart
ModulesRegisterEntry.registerAll();
```

### 1. 创建业务模块

实现 `ModuleRegistrar` 接口：

```dart
// lib/modules/your_module/your_module.dart
import 'package:flutter/material.dart';
import '../../core/module_registry/module_registrar.dart';
import '../../core/module_registry/module_registry.dart';

class YourCustomModule implements ModuleRegistrar {
  @override
  String get moduleName => 'your_custom_module';

  @override
  void register() {
    final registry = ModuleRegistry();

    // 注册国际化翻译（如果有）
    LocalizationService().registerModuleTranslations(yourTranslations);

    // 注册导航页面
    _registerNavigation(registry);

    // 注册顶栏按钮
    _registerAppBarActions(registry);

    // 注册侧边栏底部组件
    _registerSidebarFooters(registry);

    // 注册引导步骤
    _registerWizardSteps(registry);

    // 注册设置页面
    _registerSettingsPages(registry);
  }

  void _registerNavigation(ModuleRegistry registry) {
    registry.navigation.register(
      (context) => NavigationItem(
        id: 'your_page',
        title: 'Your Page'.tr(context),
        icon: Icons.dashboard,
        activeIcon: Icons.dashboard_rounded,
        page: const YourPage(),
      ),
    );
  }

  void _registerAppBarActions(ModuleRegistry registry) {
    registry.appBarActions.register(
      'your_action',
      () => YourAppBarAction(),
    );
  }

  void _registerSidebarFooters(ModuleRegistry registry) {
    registry.sidebarFooters.register(
      'your_footer',
      () => YourSidebarFooter(),
    );
  }

  void _registerWizardSteps(ModuleRegistry registry) {
    registry.wizardSteps.register(
      'your_step',
      () => YourWizardStep(),
    );
  }

  void _registerSettingsPages(ModuleRegistry registry) {
    registry.settingsPages.register(
      'your_settings',
      () => YourSettingsPage(),
    );
  }
}
```

### 1.1 模块国际化（i18n）

建议在模块内维护专属翻译与 key，并使用命名空间前缀避免冲突：

```dart
class YourLocalizationKeys {
  static const String title = 'your_module.title';
}

final Map<String, Map<String, String>> yourTranslations = {
  'zh_CN': {YourLocalizationKeys.title: '模块标题'},
  'en_US': {YourLocalizationKeys.title: 'Module Title'},
};

LocalizationService().registerModuleTranslations(yourTranslations);
```

### 2. 注册导航页面

导航页面会显示在侧边栏中：

```dart
class NavigationItem {
  final String id;              // 唯一标识
  final String title;           // 显示标题（支持国际化）
  final IconData icon;          // 未选中图标
  final IconData activeIcon;    // 选中图标
  final Widget page;            // 页面组件
  final String? badge;          // 徽章文本（可选）
}

// 注册示例
registry.navigation.register(
  (context) => NavigationItem(
    id: 'dashboard',
    title: LocalizationKeys.dashboard.tr(context),
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    page: const DashboardPage(),
    badge: '5',  // 显示未读数量
  ),
);
```

### 3. 注册顶栏按钮 (AppBarAction)

顶栏按钮显示在应用右上角：

```dart
class YourAppBarAction extends AppBarAction {
  YourAppBarAction() : super(id: 'your_action', priority: 10);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
        // 处理点击事件
      },
      tooltip: 'Search',
    );
  }
}

// 注册
registry.appBarActions.register('your_action', () => YourAppBarAction());
```

**优先级说明**：数字越小越靠左，建议范围 0-100。

### 4. 注册侧边栏底部组件 (SidebarFooter)

侧边栏底部组件用于显示用户信息、状态等：

```dart
class YourSidebarFooter extends SidebarFooter {
  YourSidebarFooter() : super(id: 'your_footer', priority: 100);

  @override
  Widget buildExpanded(BuildContext context) {
    // 侧边栏展开时的显示
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.info),
          SizedBox(width: 8),
          Text('Status: Online'),
        ],
      ),
    );
  }

  @override
  Widget buildCollapsed(BuildContext context) {
    // 侧边栏收起时的显示
    return Container(
      padding: const EdgeInsets.all(6),
      child: Icon(Icons.info),
    );
  }
}

// 注册
registry.sidebarFooters.register('your_footer', () => YourSidebarFooter());
```

### 5. 注册引导步骤 (WizardStep)

引导步骤在首次启动时显示：

```dart
class YourWizardStep extends WizardStep {
  @override
  String get id => 'your_step';

  @override
  String get title => 'Welcome';

  @override
  int get priority => 50;  // 数字越小越靠前

  @override
  bool canGoNext() {
    // 返回是否可以进入下一步
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to the app!'),
    );
  }

  @override
  Map<String, String>? getSummary() {
    // 返回配置摘要（可选）
    return {'Language': 'English'};
  }

  @override
  Future<void> onComplete() async {
    // 步骤完成时的回调（可选）
  }

  @override
  Future<void> onInit() async {
    // 步骤初始化时的回调（可选）
  }
}

// 注册
registry.wizardSteps.register('your_step', () => YourWizardStep());
```

### 6. 注册设置页面 (SettingsPageItem)

设置页面会自动添加到设置菜单中：

```dart
class YourSettingsPage extends SettingsPageItem {
  @override
  String get id => 'your_settings';

  @override
  String getTitle(BuildContext context) {
    return 'Advanced Settings'.tr(context);
  }

  @override
  String? getDescription(BuildContext context) {
    return 'Configure advanced options'.tr(context);
  }

  @override
  IconData get icon => Icons.settings_applications;

  @override
  int get priority => 80;  // 数字越小越靠前

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          // 你的设置内容
        ],
      ),
    );
  }
}

// 注册
registry.settingsPages.register('your_settings', () => YourSettingsPage());
```

**重要**：`getTitle()` 和 `getDescription()` 方法接受 `BuildContext` 参数，支持动态国际化。

### 7. 注册清理回调

在应用关闭时执行清理操作：

```dart
// 在模块的 register() 方法中
ModuleRegistry().registerCleanup(() async {
  AppLogger.info('[Cleanup] Cleaning up your module...');
  await yourService.dispose();
});
```

---

## 🛠️ 核心 API 说明

### 1. 日志系统 (`AppLogger`)

[logger.dart](/lib/core/utils/logger.dart) 提供多环境支持与自动分割：

```dart
// 记录普通信息
AppLogger.info('Application started');

// 记录警告
AppLogger.warning('Low memory');

// 记录错误（自动保存至 error.log）
AppLogger.error('Failed to load data', error, stackTrace);

// 记录调试信息
AppLogger.debug('Debug info');
```

**特性**：

- 日志自动保存到数据存储路径下的 `logs/` 目录
- 支持日志文件自动分割（默认 10MB）
- 错误日志单独存储在 `error.log`

### 2. 持久化存储 (`PersistenceService`)

[persistence_service.dart](/lib/core/services/persistence_service.dart) 负责数据存储与路径管理：

```dart
final persistence = PersistenceService();

// 保存数据
await persistence.set('user_name', 'John');
await persistence.set('settings', {'theme': 'dark'});

// 读取数据
String? userName = persistence.get<String>('user_name');
Map<String, dynamic>? settings = persistence.get<Map<String, dynamic>>('settings');

// 删除数据
await persistence.remove('user_name');

// 清除所有数据并重启应用
await persistence.resetApp();
```

**路径安全逻辑**：

- 自动清洗路径中的特殊字符
- 强制追加应用名称作为子目录（如：`D:\Data\OwO! Dashboard`）
- 确保数据隔离，防止误删其他应用数据

### 3. 国际化服务 (`LocalizationService`)

[localization_service.dart](/lib/core/services/localization_service.dart) 提供动态语言切换：

```dart
final localization = LocalizationService();

// 切换语言
await localization.setLocale(const Locale('zh', 'CN'));
await localization.setLocale(const Locale('en', 'US'));

// 获取当前语言
Locale currentLocale = localization.currentLocale;

// 使用翻译（扩展方法）
Text(LocalizationKeys.welcome.tr(context))

// 注册模块专属翻译
localization.registerModuleTranslations({
  'zh_CN': {'module.key': '翻译'},
  'en_US': {'module.key': 'Translation'},
});
```

**建议**：模块内翻译使用命名空间前缀（如：`example.*`），避免与核心 key 冲突。

### 4. 存储路径选择组件 (`StoragePathTile`)

用于展示与选择应用数据存储路径，支持“仅展示路径 + 按钮更改”的交互形式：

```dart
StoragePathTile(
  currentPath: currentPath,
  onPathSelected: (path) => updatePath(path),
  showHeader: false,
  contentPadding: EdgeInsets.zero,
  enableTap: false,
  showChangeButton: true,
)
```

### 5. 通知服务 (`NotificationService`)

[notification_service.dart](/lib/core/services/notification_service.dart) 提供应用内通知：

```dart
final notification = NotificationService();

// 显示成功通知
notification.showSuccess('操作成功');

// 显示错误通知
notification.showError('操作失败');

// 显示信息通知
notification.showInfo('这是一条提示');

// 显示警告通知
notification.showWarning('请注意');
```

### 6. 字体与资源管理 (`FontService`)

[font_service.dart](/lib/core/services/font_service.dart) 处理字体的动态加载：

```dart
final fontService = FontService();

// 初始化（自动加载字体）
await fontService.initialize();
```

**特性**：

- 首次初始化后，自动将 `AppData\Roaming` 下的资源移动到用户指定的存储路径
- 支持 `.ttf` 字体的动态注册，无需在 `pubspec.yaml` 中硬编码

### 7. 版本号管理 (`AppConstants`)

[app_constants.dart](/lib/core/constants/app_constants.dart) 集中管理应用常量：

```dart
// 应用信息
AppConstants.appName          // 'OwO! Dashboard'
AppConstants.appVersion       // '0.0.1'
AppConstants.appBuildVersion  // '2026021101'

// 开发者信息
AppConstants.developerName    // 'HanskiJay'
AppConstants.developerEmail   // 'support@owoblog.com'

// 外部链接
AppConstants.githubRepoUrl    // GitHub 仓库地址
AppConstants.donationUrl      // 捐赠链接
```

**重要**：所有版本号获取必须通过 `AppConstants.appVersion`，确保全局一致。

### 8. 版本更新检测系统 (`UpdateService`)

应用内置了完整的版本更新检测系统，支持自动检测和手动检测。

#### 功能特性

- ✅ **自动检测**：应用启动后自动检查更新（延迟3秒，静默失败）
- ✅ **手动检测**：设置 → 常规设置 → 检查更新按钮
- ✅ **智能提示**：使用SnackBar和Dialog提供友好反馈

#### 配置方法

##### **步骤1：创建配置方法**

在任意模块或启动入口中创建 `setupUpdateConfig()` 方法：

```dart
import 'package:owo_dashboard/core/module_registry/update/update_config.dart';

void setupUpdateConfig() {
  UpdateConfig.setCustomConfig(
    const UpdateConfig(
      // 必填：版本检测API地址
      versionCheckUrl: 'https://your-api.com/version',

      // 可选：默认下载地址（如果API返回的JSON中没有downloadUrl）
      downloadUrl: 'https://your-website.com/download',

      // 可选：请求超时时间（秒），默认10秒
      timeoutSeconds: 15,
    ),
  );
}
```

##### **步骤2：注册配置**

在 `lib/modules/modules_register_entry.dart` 中调用：

```dart
class ModulesRegisterEntry {
  static void registerAll() {
    // 配置版本更新检测
    setupUpdateConfig();

    // 注册其他模块...
    final registry = ModuleRegistry();
    registry.registerModule(ExampleModule());
    // ...
  }
}
```

##### **步骤3：准备API接口**

创建一个返回JSON格式的API接口：

```json
{
  "version": "1.0.1",
  "description": "修复了若干bug\n新增了某某功能",
  "downloadUrl": "https://example.com/download/app-v1.0.1.exe"
}
```

#### API接口规范

| 字段 | 类型 | 必填 | 说明 |
| ------ | ------ | ------ | ------ |
| version | String | 是 | 最新版本号，格式：x.y.z（如：1.0.1） |
| description | String | 否 | 更新内容描述，支持换行符\n |
| downloadUrl | String | 否 | 下载地址，如果为空则使用配置中的默认地址 |

#### 版本号比较规则

- 采用语义化版本号（Semantic Versioning）
- 格式：主版本号.次版本号.修订号（如：1.2.3）
- 从左到右逐位比较数字大小
- 示例：1.0.1 > 1.0.0，2.0.0 > 1.9.9

#### 使用场景

**自动检测**：应用启动后自动检测（延迟3秒）

- 有新版本 → 弹出更新对话框
- 无新版本 → 静默，不打扰用户
- 检测失败 → 静默，仅记录日志

**手动检测**：用户在"设置 > 常规设置"中点击"检查更新"

- 显示"正在检查更新..."提示
- 有新版本 → 弹出更新对话框
- 无新版本 → 显示"已是最新版本"
- 检测失败 → 显示错误信息

#### 注意事项

1. **默认配置**：空
   - **Debug模式**：未配置时会弹出提示对话框，提醒开发者配置更新服务
   - **Release模式**：未配置时静默跳过，不会发起任何网络请求
2. **版本号格式**：必须使用 x.y.z 格式（如：1.0.1），不要添加 'v' 前缀
3. **网络权限**：确保应用有网络访问权限
4. **HTTPS推荐**：建议使用HTTPS协议的API地址

#### 示例代码

查看完整示例：

- 配置示例：`lib/core/module_registry/update/update_config.dart`
- 使用示例：`lib/modules/example_module/update_config_example.dart`

#### 关联入口

- 自动检测入口：`lib/core/app.dart` 中 `MainScreen` 初始化时触发
- 手动检测入口：`lib/core/settings_pages/general_settings_page.dart` 的“检查更新”按钮

---

## 📦 依赖项

主要依赖包：

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5+1            # 状态管理
  file_picker: ^10.3.10         # 文件/目录选择
  path_provider: ^2.1.5         # 路径获取
  window_manager: ^0.5.1        # 窗口管理（桌面端）
  flutter_local_notifications: ^19.5.0  # 通知
  google_fonts: ^8.0.1          # 字体
  http: ^1.6.0                  # 网络请求
  logger: ^2.6.2                # 日志
  url_launcher: ^6.3.2          # URL 启动
  confetti: ^0.8.0              # 动效
  fl_chart: ^1.1.1              # 图表
  flex_color_picker: ^3.7.2     # 颜色选择
  flag: ^7.0.2                  # 国旗
  timezone: ^0.10.1             # 时区
  path: ^1.9.1                  # 路径工具
```

完整依赖列表请查看 [pubspec.yaml](/pubspec.yaml)。

---

## 🔒 版权与许可证

- **Copyright**: © 2023 - 2026 [OwOTeam](https://owoblog.com). All rights reserved.
- **License**: 本项目采用 **Apache License 2.0** 许可证。详见 [LICENSE](LICENSE) 文件。
- **Author**: [HanskiJay](https://github.com/Tommy131)
- **E-Mail**: [support@owoblog.com](mailto:support@owoblog.com)
- **Telegram**: [@HanskiJay](https://t.me/HanskiJay)

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的修改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

---

## 📞 联系方式

- **GitHub**: [@Tommy131](https://github.com/Tommy131)
- **Instagram**: [@jay.jay2045](https://instagram.com/jay.jay2045)
- **Email**: <support@owoblog.com>
- **Website**: [owoblog.com](https://owoblog.com)

---

<div align="center">

Made with ❤️ by OwOTeam

[⬆ 回到顶部](#owo-dashboard)

</div>
