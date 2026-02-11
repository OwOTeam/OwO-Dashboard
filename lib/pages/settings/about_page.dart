import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme_data.dart';
import '../../core/utils/url_launcher_helper.dart';

/// 关于应用页面
class AboutPage extends StatelessWidget {
  final VoidCallback? onBack;

  const AboutPage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        children: [
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                ),
              const SizedBox(width: AppThemeData.spacingSmall),
              Text('关于应用', style: theme.textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: AppThemeData.spacingLarge),
          const _AppIconCard(),
          const SizedBox(height: AppThemeData.spacingLarge),
          const _AppInfoCard(),
          const SizedBox(height: AppThemeData.spacingMedium),
          const _DeveloperCard(),
          const SizedBox(height: AppThemeData.spacingMedium),
          const _OpenSourceCard(),
          const SizedBox(height: AppThemeData.spacingMedium),
          const _CopyrightCard(),
        ],
      ),
    );
  }
}

class _AppIconCard extends StatelessWidget {
  const _AppIconCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
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
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
          const SizedBox(height: AppThemeData.spacingMedium),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(
            'Version ${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeader(icon: Icons.info_outline, title: '应用信息'),
            const Divider(height: 24),
            _ClickableInfoRow(
              label: '应用名称',
              value: AppConstants.appName,
              icon: Icons.apps_rounded,
            ),
            const SizedBox(height: 12),
            _ClickableInfoRow(
              label: '包名',
              value: AppConstants.appPackageName,
              icon: Icons.api_rounded,
            ),
            const SizedBox(height: 12),
            _ClickableInfoRow(
              label: '版本号',
              value: AppConstants.appVersion,
              icon: Icons.history_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeader(icon: Icons.code_rounded, title: '开发者信息'),
            const Divider(height: 24),
            _ClickableInfoRow(
              label: '开发者',
              value: AppConstants.developerName,
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 12),
            _ClickableInfoRow(
              label: '联系邮箱',
              value: AppConstants.developerEmail,
              icon: Icons.email_rounded,
              onTap: () => UrlLauncherHelper.launchURL(
                'mailto:${AppConstants.developerEmail}',
              ),
            ),
            const SizedBox(height: 12),
            _ClickableInfoRow(
              label: 'GitHub',
              value: AppConstants.githubUsername,
              icon: Icons.link_rounded,
              onTap: () => UrlLauncherHelper.launchURL(AppConstants.githubUrl),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenSourceCard extends StatelessWidget {
  const _OpenSourceCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppThemeData.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeader(icon: Icons.description_outlined, title: '开源许可'),
            const Divider(height: 24),
            _ClickableInfoRow(
              label: '许可协议',
              value: AppConstants.license,
              icon: Icons.gavel_rounded,
            ),
            const SizedBox(height: 12),
            _ClickableInfoRow(
              label: '项目源码',
              value: 'GitHub / OwO-Dashboard',
              icon: Icons.code_rounded,
              onTap: () =>
                  UrlLauncherHelper.launchURL(AppConstants.githubRepoUrl),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyrightCard extends StatelessWidget {
  const _CopyrightCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppThemeData.spacingSmall),
        Text(
          AppConstants.copyright,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppThemeData.spacingLarge),
      ],
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ClickableInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _ClickableInfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppThemeData.borderRadiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: onTap != null ? Theme.of(context).primaryColor : null,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
