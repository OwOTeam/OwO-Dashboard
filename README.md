# OwO! Dashboard

一个现代化的 Flutter 跨平台应用框架，专为桌面端（Windows）和移动端设计。

[![Flutter](https://img.shields.io/badge/Flutter-%5E3.9.2-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Author-HanskiJay-orange.svg)](https://github.com/Tommy131)

---

## 🏗️ 程序架构

本项目采用 **组件化、模块化** 的架构设计，核心逻辑集中在 `lib/core` 目录下，业务功能通过 `lib/modules` 进行解耦扩展。

### 核心目录结构

- `lib/core/`：核心框架层
  - `module_registry/`：模块注册与初始化中心。
  - `setup_wizard/`：引导程序框架，支持动态步骤注入。
  - `settings_pages/`：设置页面框架，支持多级菜单扩展。
  - `services/`：全局服务（持久化、通知、字体迁移、重启逻辑等）。
  - `layouts/`：响应式布局管理（桌面端/移动端自动切换）。
  - `theme/`：基于 Material 3 的全局主题与样式管理。
- `lib/modules/`：业务模块层，通过实现 `ModuleRegistrar` 接口向核心层注入功能。
- `lib/widgets/`：跨模块共享的通用组件库。

---

## 🧩 快速开发指南

应用采用注册表模式，允许开发者在不修改核心代码的情况下扩展功能。

### 1. 创建并注册业务模块

每个模块需实现 [module_registrar.dart](/lib/core/module_registry/module_registrar.dart) 接口：

```dart
class MyFeatureModule implements ModuleRegistrar {
  @override
  String get moduleName => 'my_feature';

  @override
  void register() {
    // 注册引导步骤
    WizardStepRegistry().register('my_step', () => MyWizardStep());
    // 注册设置页面
    SettingsPageRegistry().register('my_settings', () => MySettingsPage());
  }
}
```

在 [app.dart](/lib/app.dart) 中激活模块：

```dart
registry.registerModule(MyFeatureModule());
```

### 2. 添加引导步骤 (`WizardStep`)

引导步骤会自动按 `priority` 排序。继承 `WizardStep` 并实现其 build 方法：

```dart
class MyWizardStep extends WizardStep {
  @override
  String get id => 'unique_step_id';
  @override
  String get title => '欢迎使用';
  @override
  int get priority => 50; // 数值越小越靠前

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('自定义步骤内容'));
  }
}
```

### 3. 添加设置页面 (`SettingsPageItem`)

设置页面支持在主设置菜单中动态展示。

```dart
class MySettingsPage extends SettingsPageItem {
  @override
  String get id => 'my_feature_settings';
  @override
  String get label => '高级功能';
  @override
  IconData get icon => Icons.extension;

  @override
  Widget buildPage(BuildContext context, VoidCallback onBack) {
    return MySettingsDetailPage(onBack: onBack);
  }
}
```

---

## 🛠️ 核心 API 说明

### 1. 日志系统 (`AppLogger`)

[logger.dart](/lib/core/utils/logger.dart) 提供多环境支持与自动分割：

- `AppLogger.info("message")`：记录普通信息。
- `AppLogger.error("msg", e, s)`：记录错误及堆栈（自动保存至 `error.log`）。
- **特性**：日志目录会自动追加在数据存储路径下，支持用户自定义分割大小。

### 2. 持久化存储 (`PersistenceService`)

[persistence_service.dart](/lib/core/services/persistence_service.dart) 负责数据存储与路径管理：

- `PersistenceService().set('key', value)` / `get<T>('key')`。
- **路径安全逻辑**：系统会自动清洗路径中的特殊字符，并**强制追加应用名称**作为子目录（例如：`D:\Data\OwO! Dashboard`），确保数据隔离。
- `PersistenceService().resetApp()`：一键清除所有配置并**自动重启**应用。

### 3. 字体与资源管理 (`FontService`)

[font_service.dart](/lib/core/services/font_service.dart) 处理 Windows 系统资源的自动搬迁：

- 首次初始化后，自动将 `AppData\Roaming` 下的资源移动到用户指定的存储路径。
- 支持 `.ttf` 字体的动态注册，无需在 `pubspec.yaml` 中硬编码。

---

## 🔒 版权与许可证

- **Copyright**: © 2023 - 2026 [OwOTeam-DGMT (OwOBlog)](https://owoblog.com). All rights reserved.
- **License**: 本项目采用 **Apache License 2.0** 许可证。
- **Author**: [HanskiJay](https://github.com/Tommy131)
- **E-Mail**: [support@owoblog.com](mailto:support@owoblog.com)

---

## 🚀 运行环境

- **Flutter SDK**: ^3.9.2
- **Supported Platforms**: Windows (Primary), Android, iOS.
