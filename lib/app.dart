import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/layouts/desktop_layout.dart';
import 'core/layouts/mobile_layout.dart';
import 'core/layouts/responsive.dart';
import 'core/models/navigation_item.dart';
import 'core/widgets/common/dialog.dart';
import 'core/widgets/desktop/custom_title_bar.dart';
import 'pages/explore/explore_page.dart';
import 'pages/home/home_page.dart';
import 'pages/messages/messages_page.dart';
import 'pages/notifications/notification_demo_page.dart';
import 'pages/notifications/notifications_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/settings/settings_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme.generateLightTheme(),
            darkTheme: themeProvider.currentTheme.generateDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WindowListener {
  int _selectedIndex = 0;

  // 定义导航项
  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      id: 'home',
      title: '首页',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      page: HomePage(),
    ),
    NavigationItem(
      id: 'explore',
      title: '探索',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      page: ExplorePage(),
    ),
    NavigationItem(
      id: 'messages',
      title: '消息',
      icon: Icons.message_outlined,
      activeIcon: Icons.message,
      page: MessagesPage(),
      badge: '3', // 示例徽章
    ),
    NavigationItem(
      id: 'notifications',
      title: '通知',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      page: NotificationsPage(),
      badge: '12', // 示例徽章
    ),
    NavigationItem(
      id: 'notifications_demo',
      title: '通知测试页',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      page: NotificationDemoPage(),
    ),
    NavigationItem(
      id: 'profile',
      title: '我的',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      page: ProfilePage(),
    ),
    NavigationItem(
      id: 'settings',
      title: '设置',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      page: SettingsPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _init();
  }

  void _init() async {
    // Add this line to override the default close handler
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _onNavigationChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        if (!Platform.isAndroid && !Platform.isIOS) ...[
          CustomTitleBar(title: Text(AppConstants.appName)),
          Divider(height: 1, color: Color(isDark ? 0xFF313131 : 0xFFD6D6D6)),
        ],
        Expanded(
          child: Responsive(
            // 移动端布局
            mobile: MobileLayout(
              navigationItems: _navigationItems,
              selectedIndex: _selectedIndex,
              onNavigationChanged: _onNavigationChanged,
            ),
            // 桌面端布局
            desktop: DesktopLayout(
              navigationItems: _navigationItems,
              selectedIndex: _selectedIndex,
              onNavigationChanged: _onNavigationChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      final result = await showAdvancedConfirmDialog(
        context: context,
        title: '确认退出程序吗?',
        content: '', // 现在内容为空时会自动优化间距
        icon: Icons.warning_amber_rounded,
        confirmColor: Colors.redAccent,
        confirmText: '确认',
        cancelText: '取消',
      );

      if (result == true && mounted) {
        // 展示关闭中的弹窗，提供更好的视觉反馈
        _showClosingDialog();

        // 延迟一小段时间让弹窗显示出来
        await Future.delayed(const Duration(milliseconds: 300));

        // 执行清理操作
        await _handleAppCleanup();

        // 销毁窗口
        await windowManager.destroy();
      }
    }
  }

  /// 显示关闭中的提示弹窗
  void _showClosingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 20),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 20),
                Text(
                  '正在关闭应用...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请稍候，正在保存数据',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 集中处理关闭前的清理工作
  Future<void> _handleAppCleanup() async {
    try {
      // 在这里集中处理所有需要最后保存或清理的操作
      debugPrint('开始执行应用清理操作...');

      debugPrint('应用清理完成。');
    } catch (e) {
      debugPrint('清理过程中出错: $e');
    }
  }
}
