import 'package:flutter/material.dart';
import 'navigation_item.dart';

/// 导航项注册表
class NavigationRegistry {
  static final NavigationRegistry _instance = NavigationRegistry._internal();
  factory NavigationRegistry() => _instance;
  NavigationRegistry._internal();

  final List<NavigationItem Function(BuildContext)> _itemFactories = [];

  /// 注册导航项
  void register(NavigationItem Function(BuildContext) factory) {
    _itemFactories.add(factory);
  }

  /// 获取所有已注册的导航项
  List<NavigationItem> getAllItems(BuildContext context) {
    return _itemFactories.map((factory) => factory(context)).toList();
  }

  /// 清空所有注册
  void clear() {
    _itemFactories.clear();
  }
}
