import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';

import '../auth/active_account_store.dart';
import '../auth/auth_coordinator.dart';

enum _GuestConflictChoice {
  merge,
  keep,
  discard,
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  static const routeName = '/auth';

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _InkWashBackground extends StatelessWidget {
  const _InkWashBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.surface,
                scheme.surfaceContainerLow,
                scheme.surface,
              ],
              stops: const [0, 0.55, 1],
            ),
          ),
        ),
        Positioned(
          top: -140,
          left: -80,
          child: _InkBloom(
            color: scheme.primary.withValues(alpha: 0.18),
            size: 320,
          ),
        ),
        Positioned(
          bottom: -180,
          right: -100,
          child: _InkBloom(
            color: scheme.tertiary.withValues(alpha: 0.14),
            size: 380,
          ),
        ),
      ],
    );
  }
}

class _InkBloom extends StatelessWidget {
  const _InkBloom({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
            stops: const [0, 1],
          ),
        ),
      ),
    );
  }
}

class _AuthPageState extends State<AuthPage> {
  final _newPasswordController = TextEditingController();

  bool _busy = false;
  String? _error;

  ColorScheme _inkWashScheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    const paper = Color(0xFFF6F2E9);
    const ink = Color(0xFF1F2328);
    const seal = Color(0xFFC2453D);
    const bamboo = Color(0xFF3D6B4F);

    if (!isDark) {
      return ColorScheme(
        brightness: Brightness.light,
        primary: ink,
        onPrimary: paper,
        secondary: bamboo,
        onSecondary: paper,
        tertiary: const Color(0xFFB89B4A),
        onTertiary: paper,
        error: seal,
        onError: Colors.white,
        surface: paper,
        onSurface: ink,
        surfaceContainerLow: const Color(0xFFF3EDE1),
        surfaceContainer: const Color(0xFFEFE7D8),
        onSurfaceVariant: const Color(0xFF4D4A45),
        outlineVariant: const Color(0xFFD8D0C1),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: ink,
        onInverseSurface: paper,
        inversePrimary: const Color(0xFFECE3D0),
      );
    }

    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFECE3D0),
      onPrimary: Color(0xFF111316),
      secondary: Color(0xFFA8D3B2),
      onSecondary: Color(0xFF121513),
      tertiary: Color(0xFFE2C885),
      onTertiary: Color(0xFF15120E),
      error: Color(0xFFD16A64),
      onError: Color(0xFF1A0E0E),
      surface: Color(0xFF121415),
      onSurface: Color(0xFFECE3D0),
      surfaceContainerLow: Color(0xFF191B1C),
      surfaceContainer: Color(0xFF1E2022),
      onSurfaceVariant: Color(0xFFBEB6A6),
      outlineVariant: Color(0xFF3B3C3E),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFF6F2E9),
      onInverseSurface: Color(0xFF1F2328),
      inversePrimary: Color(0xFF1F2328),
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      setState(() {
        _error = context.read<AuthCoordinator>().formatAuthError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = context.watch<ActiveAccountStore>();
    final coordinator = context.read<AuthCoordinator>();

    if (!active.isSignedIn) {
      final base = Theme.of(context);
      final scheme = _inkWashScheme(base.colorScheme.brightness);
      final theme = base.copyWith(
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.primary, width: 1.4),
          ),
        ),
      );

      final cardTheme = CardTheme(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
      );

      final loginTheme = LoginTheme(
        primaryColor: scheme.surface,
        accentColor: scheme.primary,
        errorColor: scheme.error,
        cardTheme: cardTheme,
        titleStyle: base.textTheme.headlineSmall?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
        ),
        bodyStyle: base.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.5,
        ),
        textFieldStyle: base.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
        ),
        buttonStyle: base.textTheme.titleMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      );

      return Theme(
        data: theme,
        child: Stack(
          children: [
            const Positioned.fill(child: _InkWashBackground()),
            FlutterLogin(
              title: '玄 · 账号',
              userType: LoginUserType.email,
              theme: loginTheme,
              messages: LoginMessages(
                userHint: '邮箱',
                passwordHint: '密码',
                confirmPasswordHint: '确认密码',
                loginButton: '登录',
                signupButton: '注册',
                forgotPasswordButton: '忘记密码？',
                recoverPasswordButton: '发送重置邮件',
                goBackButton: '返回',
                confirmPasswordError: '两次输入的密码不一致',
              ),
              onLogin: (data) async {
                try {
                  await coordinator.signInWithEmailPassword(
                    email: data.name.trim(),
                    password: data.password,
                  );
                  return null;
                } on GuestAccountConflict catch (c) {
                  if (!mounted) return '页面已关闭，请重试';

                  final choice = await showDialog<_GuestConflictChoice>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('检测到游客数据'),
                      content: const Text(
                        '登录的账号与本机游客空间不同。请选择：\n\n- 合并：把游客期数据迁移到该账号\n- 保留：账号与游客空间独立\n- 丢弃：清空游客空间后登录',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(ctx).pop(_GuestConflictChoice.keep),
                          child: const Text('保留'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx)
                              .pop(_GuestConflictChoice.discard),
                          child: const Text('丢弃'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(ctx).pop(_GuestConflictChoice.merge),
                          child: const Text('合并'),
                        ),
                      ],
                    ),
                  );

                  if (choice == null) return '已取消登录';

                  final delegate = context.read<GuestAccountConflictDelegate?>();
                  if (delegate == null &&
                      (choice == _GuestConflictChoice.merge ||
                          choice == _GuestConflictChoice.discard)) {
                    return '缺少合并实现：请在主工程注入 GuestAccountConflictDelegate';
                  }

                  try {
                    if (choice == _GuestConflictChoice.merge) {
                      await delegate!.mergeGuestIntoAccount(
                        guestAppUserId: c.guestAppUserId,
                        accountAppUserId: c.accountAppUserId,
                      );
                    } else if (choice == _GuestConflictChoice.discard) {
                      await delegate!.discardGuest(guestAppUserId: c.guestAppUserId);
                    }

                    await coordinator.activateSession(c.session);
                    return null;
                  } catch (e) {
                    return coordinator.formatAuthError(e);
                  }
                } catch (e) {
                  return coordinator.formatAuthError(e);
                }
              },
              onSignup: (data) async {
                try {
                  await coordinator.signInOrRegisterWithEmailPassword(
                    email: data.name?.trim() ?? '',
                    password: data.password ?? '',
                  );
                  return null;
                } catch (e) {
                  return coordinator.formatAuthError(e);
                }
              },
              onRecoverPassword: (email) async {
                try {
                  await coordinator.sendPasswordResetEmail(email: email.trim());
                  return null;
                } catch (e) {
                  return coordinator.formatAuthError(e);
                }
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('账号'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                Text('当前 appUserId: ${active.activeAppUserId}'),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(labelText: '新密码'),
                  obscureText: true,
                  enabled: !_busy,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() async {
                            await coordinator.updatePassword(
                              newPassword: _newPasswordController.text,
                            );
                          }),
                  child: Text(_busy ? '处理中…' : '修改密码'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed:
                      _busy ? null : () => _run(() => coordinator.signOut()),
                  child: const Text('退出登录'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: _busy
                      ? null
                      : () => _run(() async {
                            final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('注销账号'),
                                    content: const Text(
                                      '将尝试删除 Firebase 账号；若要求近期登录可能会失败。',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('取消'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text('确认'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (!confirmed) return;
                            await coordinator.deleteAccount();
                          }),
                  child: Text(_busy ? '处理中…' : '注销账号'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
