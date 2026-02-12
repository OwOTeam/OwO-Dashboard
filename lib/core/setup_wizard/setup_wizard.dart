import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import '../constants/app_constants.dart';
import 'wizard_controller.dart';
import '../widgets/common/dialog.dart';
import 'steps/storage_path_step.dart';
import 'steps/log_settings_step.dart';
import 'steps/summary_step.dart';
import 'wizard_step_registry.dart';

class SetupWizard extends StatefulWidget {
  final VoidCallback? onCompleted;
  const SetupWizard({super.key, this.onCompleted});

  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> with WindowListener {
  late final WizardController _controller;
  late final ConfettiController _confettiController;
  bool _showCompletionAnimation = false;
  bool _showWelcomePage = true; // 欢迎页面状态

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    windowManager.setPreventClose(true);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // 1. 获取核心步骤
    final coreSteps = [StoragePathStep(), LogSettingsStep(), SummaryStep()];

    // 2. 获取注册的自定义步骤
    final customSteps = WizardStepRegistry().getAllSteps();

    // 3. 合并并排序所有步骤
    final allSteps = [...coreSteps, ...customSteps];
    allSteps.sort((a, b) => a.priority.compareTo(b.priority));

    // 只包含实际的配置步骤，不包括欢迎页面
    _controller = WizardController(steps: allSteps)
      ..onCompleted = _onWizardCompleted;

    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    setState(() {}); // Rebuild to reflect controller changes
  }

  void _onWizardCompleted() {
    setState(() {
      _showCompletionAnimation = true;
    });

    // 触发撒花动画
    _confettiController.play();

    // 延迟后调用实际的完成回调
    Future.delayed(const Duration(seconds: 3), () {
      widget.onCompleted?.call();
    });
  }

  /// 从欢迎页面进入配置步骤
  void _startConfiguration() {
    setState(() {
      _showWelcomePage = false;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _confettiController.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // 无论在哪个页面，关闭窗口都需要确认
    final result = await showAdvancedConfirmDialog(
      context: context,
      title: _showWelcomePage ? '确认退出' : '配置尚未完成',
      content: _showWelcomePage ? '确定要退出应用吗？' : '退出应用将导致配置丢失，确认要退出吗？',
      icon: Icons.warning_amber_rounded,
      confirmColor: Colors.redAccent,
      confirmText: '退出',
      cancelText: '取消',
    );

    if (result == true) {
      await windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: _showWelcomePage
                  ? _buildWelcomePage(context)
                  : _SetupWizardContent(),
            ),
            // 完成动画覆盖层
            if (_showCompletionAnimation) _buildCompletionAnimation(context),
            // 左下角撒花 - 向右上方喷射
            Align(
              alignment: Alignment.bottomLeft,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -pi / 4, // 向右上（45度）
                emissionFrequency: 0.03,
                numberOfParticles: 25,
                maxBlastForce: 80,
                minBlastForce: 40,
                gravity: 0.2,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                  Colors.amber,
                  Colors.pink,
                  Colors.purple,
                ],
              ),
            ),
            // 右下角撒花 - 向左上方喷射
            Align(
              alignment: Alignment.bottomRight,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -3 * pi / 4, // 向左上（135度）
                emissionFrequency: 0.03,
                numberOfParticles: 25,
                maxBlastForce: 80,
                minBlastForce: 40,
                gravity: 0.2,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                  Colors.amber,
                  Colors.pink,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionAnimation(BuildContext context) {
    return AnimatedOpacity(
      opacity: _showCompletionAnimation ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.95),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 120,
                      color: Colors.white.withValues(alpha: value),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Text(
                      '一切准备就绪',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: const Text(
                      '正在启动应用...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建欢迎页面
  Widget _buildWelcomePage(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App 图标
            Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    AppConstants.assetIconPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.dashboard_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 欢迎标题
            Text(
              '欢迎使用 ${AppConstants.appName}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // 描述文本
            const Text(
              '在开始之前，我们需要引导您完成一些基础配置。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 48),
            // 开始按钮
            FilledButton.icon(
              onPressed: _startConfiguration,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('开始配置'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '让我们开始吧！',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupWizardContent extends StatelessWidget {
  const _SetupWizardContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WizardController>();

    if (controller.isCompleted) {
      // 完成后的回调，通常在 build 之后通过 postFrameCallback 触发导航
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 重新启动应用或进入主页
        // 这里假设会在外层监听状态
      });
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context, controller),
            const SizedBox(height: 32),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(context, controller),
              ),
            ),
            const SizedBox(height: 32),
            _buildFooter(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WizardController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '配置引导',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  controller.currentStepTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            Text(
              '还剩 ${controller.remainingItems} 项',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: controller.progress,
            minHeight: 8,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep(BuildContext context, WizardController controller) {
    return KeyedSubtree(
      key: ValueKey(controller.currentStep),
      child: controller.currentStepInstance.build(context),
    );
  }

  Widget _buildFooter(BuildContext context, WizardController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (controller.currentStep > 0)
          TextButton.icon(
            onPressed: controller.previousStep,
            icon: const Icon(Icons.arrow_back),
            label: const Text('上一步'),
          )
        else
          const SizedBox(),
        ElevatedButton(
          onPressed: controller.canGoNext ? controller.nextStep : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleAtMost(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            controller.currentStep == controller.totalSteps - 1
                ? '完成初始化'
                : '下一步',
          ),
        ),
      ],
    );
  }
}

// 修正 RoundedRectangleAtMost 为 RoundedRectangleBorder
class RoundedRectangleAtMost extends RoundedRectangleBorder {
  const RoundedRectangleAtMost({super.borderRadius});
}
