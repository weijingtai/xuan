import 'dart:math' as math;

import 'package:account/account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  static const routeName = '/profile';

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  bool _busy = false;
  String? _error;

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
    final store = context.watch<ActiveAccountStore>();
    final coordinator = context.read<AuthCoordinator>();
    final firebaseAuth = context.read<FirebaseAuth?>();
    final userEmail = firebaseAuth?.currentUser?.email;
    final appUserId = store.activeAppUserId ?? '';
    final displayName =
        _displayNameFromEmail(userEmail) ?? _shortAppUserId(appUserId);

    final theme = Theme.of(context);
    final scheme = _inkWashScheme(theme.colorScheme.brightness);
    final isCompact = MediaQuery.sizeOf(context).width < 920;
    final pagePadding = EdgeInsets.all(isCompact ? 16 : 24);

    return Theme(
      data: theme.copyWith(
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('个人档案'),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                          final ok = await _confirmSignOut(context);
                          if (!ok) return;
                          await coordinator.signOut();
                        }),
                style: TextButton.styleFrom(
                  foregroundColor: scheme.error,
                ),
                child: const Text('登出'),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: _InkWashBackground()),
            SafeArea(
              child: Padding(
                padding: pagePadding,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 920) {
                          return _MobileLayout(
                            error: _error,
                            busy: _busy,
                            displayName: displayName,
                            userEmail: userEmail,
                            appUserId: appUserId,
                            onSignOut: () => _run(() async {
                              final ok = await _confirmSignOut(context);
                              if (!ok) return;
                              await coordinator.signOut();
                            }),
                          );
                        }

                        return _DesktopLayout(
                          error: _error,
                          busy: _busy,
                          displayName: displayName,
                          userEmail: userEmail,
                          appUserId: appUserId,
                          onSignOut: () => _run(() async {
                            final ok = await _confirmSignOut(context);
                            if (!ok) return;
                            await coordinator.signOut();
                          }),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (_busy)
              Positioned.fill(
                child: AbsorbPointer(
                  child: ColoredBox(
                    color: scheme.surface.withValues(alpha: 0.55),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.error,
    required this.busy,
    required this.displayName,
    required this.userEmail,
    required this.appUserId,
    required this.onSignOut,
  });

  final String? error;
  final bool busy;
  final String displayName;
  final String? userEmail;
  final String appUserId;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 360,
          child: Column(
            children: [
              _ProfileHeroCard(
                displayName: displayName,
                subtitle: userEmail ?? '已登录',
              ),
              const SizedBox(height: 16),
              _ActionCard(
                busy: busy,
                onSignOut: onSignOut,
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                _ErrorCard(message: error!),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _InfoCard(
                title: '账号信息',
                children: [
                  _InfoRow(
                      label: '账号ID',
                      value: appUserId.isEmpty ? '—' : appUserId),
                  _InfoRow(label: '邮箱', value: userEmail ?? '—'),
                  _InfoRow(label: '平台', value: _platformLabel()),
                ],
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: '风格提示',
                children: [
                  _InfoRow(
                      label: '主题',
                      value:
                          scheme.brightness == Brightness.dark ? '墨夜' : '宣纸'),
                  const _Keyline(),
                  Text(
                    '留白为骨，克制为韵。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.6,
                          letterSpacing: 0.3,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.error,
    required this.busy,
    required this.displayName,
    required this.userEmail,
    required this.appUserId,
    required this.onSignOut,
  });

  final String? error;
  final bool busy;
  final String displayName;
  final String? userEmail;
  final String appUserId;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        _ProfileHeroCard(
          displayName: displayName,
          subtitle: userEmail ?? '已登录',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: '账号信息',
          children: [
            _InfoRow(label: '账号ID', value: appUserId.isEmpty ? '—' : appUserId),
            _InfoRow(label: '邮箱', value: userEmail ?? '—'),
            _InfoRow(label: '平台', value: _platformLabel()),
          ],
        ),
        const SizedBox(height: 12),
        _ActionCard(busy: busy, onSignOut: onSignOut),
        if (error != null) ...[
          const SizedBox(height: 12),
          _ErrorCard(message: error!),
        ],
        const SizedBox(height: 12),
        _InfoCard(
          title: '一句话',
          children: [
            Text(
              '松风入墨，心自澄明。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.displayName, required this.subtitle});

  final String displayName;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        );

    return _SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _SealAvatar(seed: displayName),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: titleStyle),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _InkTag(text: '简约'),
                      _InkTag(text: '国风'),
                      _InkTag(text: '克制'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _VerticalSeal(),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.busy, required this.onSignOut});

  final bool busy;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '操作',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: busy ? null : onSignOut,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('登出'),
            ),
            const SizedBox(height: 10),
            Text(
              '登出会清除本机的激活账号，并回到登录页。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6),
            ),
            const SizedBox(height: 12),
            ..._interleave(children, const SizedBox(height: 10)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _SurfaceCard(
      borderColor: scheme.error.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.error,
                height: 1.5,
              ),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final outline =
        borderColor ?? scheme.outlineVariant.withValues(alpha: 0.65);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: scheme.brightness == Brightness.dark ? 0.35 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _KeylinePainter(
                  color: scheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _KeylinePainter extends CustomPainter {
  _KeylinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    const step = 14.0;
    final max = math.max(size.width, size.height);
    for (double i = -max; i < max; i += step) {
      path
        ..moveTo(i, 0)
        ..lineTo(i + max, max);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _KeylinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
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
              color: scheme.primary.withValues(alpha: 0.18), size: 320),
        ),
        Positioned(
          bottom: -180,
          right: -100,
          child: _InkBloom(
              color: scheme.tertiary.withValues(alpha: 0.14), size: 380),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _MeanderPainter(
                color: scheme.outlineVariant.withValues(
                    alpha: scheme.brightness == Brightness.dark ? 0.16 : 0.22),
              ),
            ),
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

class _MeanderPainter extends CustomPainter {
  _MeanderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const bandHeight = 28.0;
    final top = Rect.fromLTWH(0, 0, size.width, bandHeight);
    final bottom =
        Rect.fromLTWH(0, size.height - bandHeight, size.width, bandHeight);

    _drawMeander(canvas, paint, top);
    _drawMeander(canvas, paint, bottom);
  }

  void _drawMeander(Canvas canvas, Paint paint, Rect rect) {
    const unit = 10.0;
    final path = Path();
    double x = rect.left + 12;
    final yTop = rect.top + rect.height / 2 - unit / 2;
    final yBottom = rect.top + rect.height / 2 + unit / 2;

    while (x < rect.right - 12) {
      path
        ..moveTo(x, yBottom)
        ..lineTo(x + unit, yBottom)
        ..lineTo(x + unit, yTop)
        ..lineTo(x + 2 * unit, yTop)
        ..lineTo(x + 2 * unit, yBottom);
      x += 3 * unit;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MeanderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SealAvatar extends StatelessWidget {
  const _SealAvatar({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = seed.isEmpty ? '玄' : seed.characters.first;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: scheme.outlineVariant, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: scheme.brightness == Brightness.dark ? 0.25 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: CircleAvatar(
        radius: 30,
        backgroundColor: scheme.surfaceContainer,
        foregroundColor: scheme.onSurface,
        child: Text(
          initial,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
        ),
      ),
    );
  }
}

class _VerticalSeal extends StatelessWidget {
  const _VerticalSeal();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.error.withValues(
            alpha: scheme.brightness == Brightness.dark ? 0.85 : 0.92),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: scheme.error.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          '玄印',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 6,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class _InkTag extends StatelessWidget {
  const _InkTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _Keyline extends StatelessWidget {
  const _Keyline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context)
            .colorScheme
            .outlineVariant
            .withValues(alpha: 0.55),
      ),
    );
  }
}

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

String _platformLabel() {
  if (kIsWeb) return 'Web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android',
    TargetPlatform.iOS => 'iOS',
    TargetPlatform.macOS => 'macOS',
    TargetPlatform.windows => 'Windows',
    TargetPlatform.linux => 'Linux',
    TargetPlatform.fuchsia => 'Fuchsia',
  };
}

String? _displayNameFromEmail(String? email) {
  if (email == null) return null;
  final trimmed = email.trim();
  if (trimmed.isEmpty) return null;
  final at = trimmed.indexOf('@');
  if (at <= 0) return trimmed;
  return trimmed.substring(0, at);
}

String _shortAppUserId(String appUserId) {
  if (appUserId.trim().isEmpty) return '用户';
  final normalized = appUserId.trim();
  if (normalized.length <= 8) return normalized;
  return '${normalized.substring(0, 4)}…${normalized.substring(normalized.length - 3)}';
}

List<Widget> _interleave(List<Widget> children, Widget separator) {
  if (children.isEmpty) return const [];
  final result = <Widget>[];
  for (int i = 0; i < children.length; i++) {
    result.add(children[i]);
    if (i != children.length - 1) result.add(separator);
  }
  return result;
}

Future<bool> _confirmSignOut(BuildContext context) async {
  final scheme = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('确认登出？'),
          content: const Text('将清除本机登录状态，并回到登录页。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: scheme.error),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('登出'),
            ),
          ],
        ),
      ) ??
      false;
  return ok;
}
