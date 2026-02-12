import 'package:flutter/material.dart';
import '../theme/app_theme_data.dart';
import 'theme_settings_page.dart';
import 'about_page.dart';
import 'general_settings_page.dart';
import 'settings_page_registry.dart';

/// 设置项配置模型
class SettingsItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function(VoidCallback onBack) builder;
  final String routeKey;

  const SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
    required this.routeKey,
  });
}

/// 设置页面的主入口，支持智能子页面注册和过渡动画
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 当前子页面路由 Key：'main' 表示主菜单
  String _currentRoute = 'main';

  // 智能注册子页面列表
  late final List<SettingsItem> _settingsItems;

  @override
  void initState() {
    super.initState();
    _settingsItems = _buildSettingsItems();
  }

  List<SettingsItem> _buildSettingsItems() {
    final items = <SettingsItem>[
      // 核心设置页面
      SettingsItem(
        title: '常规设置',
        subtitle: '管理应用存储路径及基本行为',
        icon: Icons.settings_applications_outlined,
        routeKey: 'general',
        builder: (onBack) => GeneralSettingsPage(onBack: onBack),
      ),
      SettingsItem(
        title: '主题设置',
        subtitle: '自定义应用的主题颜色和显示模式',
        icon: Icons.palette_outlined,
        routeKey: 'theme',
        builder: (onBack) => ThemeSettingsPage(onBack: onBack),
      ),
      SettingsItem(
        title: '关于应用',
        subtitle: '查看应用版本、开发者信息和许可协议',
        icon: Icons.info_outline,
        routeKey: 'about',
        builder: (onBack) => AboutPage(onBack: onBack),
      ),
    ];

    // 从注册表加载自定义设置页面
    final registry = SettingsPageRegistry();
    final customPages = registry.getAllPages();

    for (final page in customPages) {
      items.add(
        SettingsItem(
          title: page.title,
          subtitle: page.description ?? '',
          icon: page.icon,
          routeKey: page.id,
          builder: (onBack) => _CustomPageWrapper(page: page, onBack: onBack),
        ),
      );
    }

    return items;
  }

  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  void _goBack() {
    setState(() {
      _currentRoute = 'main';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // 使用更加平滑的水平移动 + 渐变效果
        final offsetAnimation =
            Tween<Offset>(
              begin: const Offset(0.05, 0.0), // 稍微偏移即可，避免过大位移感
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: _buildCurrentPage(),
    );
  }

  Widget _buildCurrentPage() {
    if (_currentRoute == 'main') {
      return _buildMainMenu();
    }

    // 根据 routeKey 自动匹配并构建子页面
    final item = _settingsItems.firstWhere(
      (element) => element.routeKey == _currentRoute,
      orElse: () => _settingsItems.first,
    );

    return KeyedSubtree(
      key: ValueKey(item.routeKey),
      child: item.builder(_goBack),
    );
  }

  Widget _buildMainMenu() {
    final theme = Theme.of(context);
    return Scaffold(
      key: const ValueKey('main_menu'),
      body: ListView(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppThemeData.spacingMedium,
            ),
            child: Text('设置', style: theme.textTheme.headlineMedium),
          ),
          const SizedBox(height: AppThemeData.spacingSmall),

          // 根据注册列表自动生成菜单卡片
          ..._settingsItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppThemeData.spacingSmall),
              child: _SettingsMenuCard(
                item: item,
                onTap: () => _navigateTo(item.routeKey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsMenuCard extends StatelessWidget {
  final SettingsItem item;
  final VoidCallback onTap;

  const _SettingsMenuCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeData.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppThemeData.spacingMedium),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 28,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 自定义页面包装器，提供返回按钮支持
class _CustomPageWrapper extends StatelessWidget {
  final dynamic page;
  final VoidCallback onBack;

  const _CustomPageWrapper({required this.page, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppThemeData.spacingMedium),
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
            const SizedBox(width: AppThemeData.spacingSmall),
            Text(page.title, style: theme.textTheme.headlineMedium),
          ],
        ),
        const SizedBox(height: AppThemeData.spacingLarge),
        page.build(context),
      ],
    );
  }
}
