import 'package:flutter/material.dart';

class TemplateEditorPane extends StatelessWidget {
  const TemplateEditorPane({
    super.key,
    required this.isLoading,
    required this.header,
    required this.sidebar,
    required this.workspace,
    required this.actionBar,
  });

  final bool isLoading;
  final Widget header;
  final Widget sidebar;
  final Widget workspace;
  final Widget actionBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1024;
        final body = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        right: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    child: sidebar,
                  ),
                  Expanded(
                    child: Container(
                      color: theme.colorScheme.surface,
                      child: workspace,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    child: sidebar,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      color: theme.colorScheme.surface,
                      child: workspace,
                    ),
                  ),
                ],
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              elevation: 1,
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: header,
              ),
            ),
            Expanded(child: body),
            Material(
              elevation: 2,
              color: theme.colorScheme.surface,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: actionBar,
              ),
            ),
          ],
        );
      },
    );
  }
}

