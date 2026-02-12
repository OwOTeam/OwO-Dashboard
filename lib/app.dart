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
import 'core/services/notification_service.dart';
import 'core/settings_pages/settings_page.dart';
import 'core/utils/logger.dart';

// 示例页面, 后续开发可删除
import 'example_pages/explore/explore_page.dart';
import 'example_pages/home/home_page.dart';
import 'example_pages/messages/messages_page.dart';
import 'example_pages/notifications/notification_demo_page.dart';
import 'example_pages/notifications/notifications_page.dart';
import 'example_pages/profile/profile_page.dart';

import 'core/services/persistence_service.dart';
import 'core/services/font_service.dart';
import 'core/setup_wizard/setup_wizard.dart';

import 'core/module_registry/module_registry.dart';
import 'modules/my_settings_pages/my_settings_pages_module.dart';
import 'modules/my_wizard_steps/my_wizard_steps_module.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSetupMode = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 初始化应用程序入口
  ///
  /// 在应用启动时调用此函数以初始化应用程序
  Future<void> _initializeApp() async {
    try {
      // 1. 尝试初始化持久化服务（使用默认路径检查之前的配置）
      final persistence = PersistenceService();
      await persistence.init();
      final configuredPath = persistence.getString('data_root_path');
      if (configuredPath != null && configuredPath != persistence.rootPath) {
        await persistence.init(customPath: configuredPath);
      }
      await AppLogger.init();

      // 2. 初始化字体服务（如果已配置路径，则加载动态字体）
      await FontService().initialize();

      // 3. 初始化所有模块
      final registry = ModuleRegistry();
      // 注册向导步骤模块
      registry.registerModule(MyWizardStepsModule());
      // 注册设置页面模块
      registry.registerModule(MySettingsPagesModule());
      // 初始化所有模块
      registry.initializeAll();

      // 3. 初始化通知服务
      final notificationService = NotificationService();
      await notificationService.initialize();

      // Add this line to override the default close handler
      await windowManager.setPreventClose(true);

      if (mounted) {
        setState(() {
          _isSetupMode = persistence.get<bool>(
            'is_first_launch',
            defaultValue: true,
          )!;
          _isInitialized = true;
        });
      }
    } catch (e, s) {
      AppLogger.error('App Initialization failed', e, s);
      // Fallback or show error? For now proceed to allow retry or debug
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
        ),
      );
    }
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme.generateLightTheme(
              adjustment: themeProvider.lightContrastAdjustment,
            ),
            darkTheme: themeProvider.currentTheme.generateDarkTheme(
              adjustment: themeProvider.darkContrastAdjustment,
            ),
            themeMode: themeProvider.themeMode,
            home: _isSetupMode
                ? SetupWizard(
                    key: ValueKey(_isSetupMode),
                    onCompleted: () => setState(() => _isSetupMode = false),
                  )
                : const MainScreen(),
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

  // 示例页面, 后续开发可删除
  final List<NavigationItem> _exampleNavigationItems = const [
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
  ];

  // 定义导航项
  final List<NavigationItem> _coreNavigationItems = const [
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
  }

  /// 集中处理关闭前的清理工作
  Future<void> _handleAppCleanup() async {
    try {
      // 在这里集中处理所有需要最后保存或清理的操作
      AppLogger.info('开始执行应用清理操作...');

      // 清理通知服务资源
      await NotificationService().dispose();

      AppLogger.info('应用清理完成。');
    } catch (e) {
      AppLogger.error('清理过程中出错: $e');
    }
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
    final navigationItems = _exampleNavigationItems + _coreNavigationItems;
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
              navigationItems: navigationItems,
              selectedIndex: _selectedIndex,
              onNavigationChanged: _onNavigationChanged,
            ),
            // 桌面端布局
            desktop: DesktopLayout(
              navigationItems: navigationItems,
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
        // 使用通用的加载弹窗，可以编写主标题、子标题，并根据 ConfirmDialogStyle 切换风格
        // 这里演示使用 material 风格（也可以尝试 glass 或 darkNeon）
        showLoadingDialog(
          context: context,
          style: ConfirmDialogStyle.material,
          title: '正在关闭应用...',
          content: '请稍候，正在保存数据',
        );

        // 延迟一小段时间让弹窗显示出来
        await Future.delayed(const Duration(milliseconds: 300));

        // 执行清理操作
        await _handleAppCleanup();

        // 销毁窗口
        await windowManager.destroy();
      }
    }
  }
}
