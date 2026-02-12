# 模块化开发指南

## 概述

本项目采用模块化架构，支持动态注册向导步骤和设置页面。

## 目录结构

```
lib/
├── core/
│   ├── module_registrar.dart          # 模块注册接口
│   ├── setup_wizard/
│   │   ├── wizard_step.dart           # 向导步骤抽象类
│   │   └── wizard_step_registry.dart  # 向导步骤注册表
│   └── settings_pages/
│       ├── settings_page_item.dart    # 设置页面抽象类
│       └── settings_page_registry.dart # 设置页面注册表
└── modules/
    ├── module_registry.dart           # 模块注册管理器
    ├── module_initializer.dart        # 模块初始化入口
    ├── my_wizard_steps/               # 自定义向导步骤模块
    │   ├── my_wizard_steps_module.dart
    │   └── steps/
    │       └── example_wizard_step.dart
    └── my_settings_pages/             # 自定义设置页面模块
        ├── my_settings_pages_module.dart
        └── pages/
            └── example_settings_page.dart
```

## 添加自定义向导步骤

### 1. 创建步骤类

在 `lib/modules/my_wizard_steps/steps/` 下创建新步骤：

```dart
import 'package:flutter/material.dart';
import '../../../core/setup_wizard/wizard_step.dart';

class MyCustomStep extends WizardStep {
  @override
  String get id => 'my_custom_step';

  @override
  String get title => '我的自定义步骤';

  @override
  int get priority => 30; // 数字越小越靠前

  @override
  bool canGoNext() {
    // 返回是否可以进入下一步
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('自定义步骤内容'),
    );
  }
}
```

### 2. 注册步骤

在 `lib/modules/my_wizard_steps/my_wizard_steps_module.dart` 中注册：

```dart
@override
void register() {
  final registry = WizardStepRegistry();
  registry.register('my_custom_step', () => MyCustomStep());
}
```

## 添加自定义设置页面

### 1. 创建页面类

在 `lib/modules/my_settings_pages/pages/` 下创建新页面：

```dart
import 'package:flutter/material.dart';
import '../../../core/settings_pages/settings_page_item.dart';

class MyCustomSettingsPage extends SettingsPageItem {
  @override
  String get id => 'my_custom_settings';

  @override
  String get title => '我的设置';

  @override
  IconData get icon => Icons.settings;

  @override
  int get priority => 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('自定义设置页面')),
    );
  }
}
```

### 2. 注册页面

在 `lib/modules/my_settings_pages/my_settings_pages_module.dart` 中注册：

```dart
@override
void register() {
  final registry = SettingsPageRegistry();
  registry.register('my_custom_settings', () => MyCustomSettingsPage());
}
```

## 优先级说明

- **向导步骤**：
  - 10: 存储路径步骤
  - 20: 日志设置步骤
  - 1000: 总结步骤（始终最后）

- **设置页面**：
  - 数字越小越靠前
  - 建议自定义页面使用 50-100 范围

## 注意事项

1. 每个步骤/页面的 `id` 必须唯一
2. 优先级决定显示顺序，数字越小越靠前
3. 总结步骤应始终保持最高优先级（1000）
4. 所有模块在 `lib/modules/module_initializer.dart` 中统一初始化
