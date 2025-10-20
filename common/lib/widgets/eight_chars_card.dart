import 'package:flutter/material.dart';

// This is a pure presentation widget that provides the card's visual shell.
class EightCharsCard extends StatelessWidget {
  final String? title;
  final Widget child;

  const EightCharsCard({Key? key, this.title, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          child,
        ],
      ),
    );
  }
}