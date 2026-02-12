import 'package:flutter/material.dart';

import '../../core/module_registry/module_registrar.dart';
import '../../core/module_registry/module_registry.dart';
import '../../core/module_registry/app_bar/app_bar_action.dart';
import '../../core/module_registry/navigation/navigation_item.dart';
import '../../core/module_registry/sidebar/sidebar_footer.dart';
import '../../core/services/localization_service.dart';
import '../../core/localization/localization_keys.dart';
import 'localization/example_translations.dart';
import 'localization/example_localization_keys.dart';

// 导入示例页面
import 'pages/explore/explore_page.dart';
import 'pages/home/home_page.dart';
import 'pages/messages/messages_page.dart';
import 'pages/notifications/notification_demo_page.dart';
import 'pages/notifications/notifications_page.dart';
import 'pages/profile/profile_page.dart';
import 'wizard/example_wizard_step.dart';
import 'pages/settings/example_settings_page.dart';

class ExampleModule implements ModuleRegistrar {
  @override
  String get moduleName => 'example_module';

  @override
  void register() {
    final registry = ModuleRegistry();

    // 1. 注册国际化翻译
    LocalizationService().registerModuleTranslations(exampleTranslations);

    // 2. 注册导航页面
    _registerNavigation(registry);

    // 3. 注册 App Bar 按钮
    _registerAppBarActions(registry);

    // 4. 注册侧边栏页脚
    _registerSidebarFooters(registry);

    // 5. 注册向导步骤
    registry.wizardSteps.register('example_step', () => ExampleWizardStep());

    // 6. 注册设置页面
    registry.settingsPages.register(
      'example_settings',
      () => ExampleSettingsPage(),
    );
  }

  void _registerNavigation(ModuleRegistry registry) {
    registry.navigation.register(
      (context) => NavigationItem(
        id: 'home',
        title: ExampleLocalizationKeys.home.tr(context),
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        page: const HomePage(),
      ),
    );

    registry.navigation.register(
      (context) => NavigationItem(
        id: 'explore',
        title: ExampleLocalizationKeys.explore.tr(context),
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        page: const ExplorePage(),
      ),
    );

    registry.navigation.register(
      (context) => NavigationItem(
        id: 'messages',
        title: ExampleLocalizationKeys.messages.tr(context),
        icon: Icons.message_outlined,
        activeIcon: Icons.message,
        page: const MessagesPage(),
        badge: '3',
      ),
    );

    registry.navigation.register(
      (context) => NavigationItem(
        id: 'notifications',
        title: ExampleLocalizationKeys.notifications.tr(context),
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        page: const NotificationsPage(),
        badge: '12',
      ),
    );

    registry.navigation.register(
      (context) => NavigationItem(
        id: 'notifications_demo',
        title: ExampleLocalizationKeys.notificationDemo.tr(context),
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        page: const NotificationDemoPage(),
      ),
    );

    registry.navigation.register(
      (context) => NavigationItem(
        id: 'profile',
        title: ExampleLocalizationKeys.profile.tr(context),
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        page: const ProfilePage(),
      ),
    );
  }

  void _registerAppBarActions(ModuleRegistry registry) {
    // 注册搜索按钮
    registry.appBarActions.register('search', () => _SearchAction());

    // 注册通知按钮
    registry.appBarActions.register(
      'notifications',
      () => _NotificationsAction(),
    );
  }

  void _registerSidebarFooters(ModuleRegistry registry) {
    registry.sidebarFooters.register('user_info', () => _UserInfoFooter());
  }
}

class _UserInfoFooter extends SidebarFooter {
  _UserInfoFooter() : super(id: 'user_info', priority: 100);

  @override
  Widget buildExpanded(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          _buildAvatar(theme),
          const SizedBox(width: 8),
          _buildUserInfo(context, theme),
        ],
      ),
    );
  }

  @override
  Widget buildCollapsed(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Center(child: _buildAvatar(theme)),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      child: Icon(Icons.person, color: theme.colorScheme.primary, size: 18),
    );
  }

  Widget _buildUserInfo(BuildContext context, ThemeData theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ExampleLocalizationKeys.defaultUserName.tr(context),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            ExampleLocalizationKeys.defaultUserEmail.tr(context),
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SearchAction extends AppBarAction {
  _SearchAction() : super(id: 'search', priority: 10);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {},
      tooltip: ExampleLocalizationKeys.search.tr(context),
    );
  }
}

class _NotificationsAction extends AppBarAction {
  _NotificationsAction() : super(id: 'notifications', priority: 20);

  @override
  Widget build(BuildContext context) {
    void onPressed() {}
    final label = ExampleLocalizationKeys.notificationsLabel.tr(context);
    final badgeLabel = LocalizationKeys.badgeLabel.tr(context);
    return Semantics(
      button: true,
      label: '$label, $badgeLabel',
      onTap: onPressed,
      child: ExcludeSemantics(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onPressed,
              tooltip: label,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
