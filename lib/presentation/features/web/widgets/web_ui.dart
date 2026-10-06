import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:flutter/material.dart';

/// Layout breakpoints shared by the web screens.
abstract class WebBreakpoints {
  /// From here on there is room for a side rail and two columns.
  static const double wide = 900;

  static bool isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= wide;
}

/// Rounded surface used for the dashboard's columns.
class WebPanel extends StatelessWidget {
  const WebPanel({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderStroke),
      ),
      child: child,
    );
  }
}

/// Icon and text in the middle of an empty area.
class WebHint extends StatelessWidget {
  const WebHint({super.key, required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: context.textSecondary),
            const SizedBox(height: 12),
            text.s(15).w(500).c(context.textSecondary).copyWith(textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Spinner with a status line, optionally with determinate progress.
class WebProgress extends StatelessWidget {
  const WebProgress({super.key, required this.text, this.progress});

  final String text;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progress == null)
              const CircularProgressIndicator()
            else
              LinearProgressIndicator(value: progress, minHeight: 6, borderRadius: BorderRadius.circular(3)),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: text.s(15).w(500).c(context.textSecondary).copyWith(textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error text with a retry button.
class WebError extends StatelessWidget {
  const WebError({super.key, required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return WebHint(
      icon: Icons.error_outline,
      text: text,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(Strings.commonRetry),
            ),
    );
  }
}

/// Small notice row: warnings in the source panel, tips in results.
class WebNotice extends StatelessWidget {
  const WebNotice({super.key, required this.text, this.icon = Icons.info_outline, this.color});

  final String text;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colors.buttonPrimary;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: tint),
            const SizedBox(width: 10),
            Expanded(child: text.s(14).w(500).c(context.textPrimary)),
          ],
        ),
      ),
    );
  }
}
