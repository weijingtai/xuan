import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';

import '../auth/active_account_store.dart';
import '../auth/auth_coordinator.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _newPasswordController = TextEditingController();

  bool _busy = false;
  String? _error;

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
      return FlutterLogin(
        title: '账号登录',
        userType: LoginUserType.email,
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
