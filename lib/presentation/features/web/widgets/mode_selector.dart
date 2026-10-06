import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/domain/models/dashboard/dashboard_button_data.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';
import 'package:flutter/material.dart';

extension WebModeInfo on DashboardButtonType {
  // Иконки берём из самого DashboardButtonType.icon(): там они уже
  // обновлены — искры для описания сцены и лупа для поиска объектов. Своя
  // копия, которая жила здесь, успела отстать и рисовала гору и машину.
  String get description => switch (this) {
        DashboardButtonType.scanText => Strings.webModeScanTextDescription,
        DashboardButtonType.scanBarcode => Strings.webModeScanBarcodeDescription,
        DashboardButtonType.describeScene => Strings.webModeDescribeSceneDescription,
        DashboardButtonType.objectRecognition => Strings.webModeObjectRecognitionDescription,
      };
}

/// The four tools: cards in a row on wide screens, pills on narrow ones.
class ModeSelector extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.compact,
  });

  final DashboardButtonType selected;
  final ValueChanged<DashboardButtonType> onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: DashboardButtonType.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final mode = DashboardButtonType.values[index];
            return _ModeTile(mode: mode, selected: mode == selected, compact: true, onTap: () => onSelected(mode));
          },
        ),
      );
    }
    // Equal heights even when a translation wraps to a second line.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final mode in DashboardButtonType.values) ...[
            if (mode != DashboardButtonType.values.first) const SizedBox(width: 12),
            Expanded(
              child: _ModeTile(mode: mode, selected: mode == selected, compact: false, onTap: () => onSelected(mode)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.mode,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final DashboardButtonType mode;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.buttonPrimary;
    final foreground = selected ? accent : context.textPrimary;
    final radius = compact ? AppGlass.chipAll : AppGlass.cardAll;
    final icon = mode.icon(context, color: foreground, size: compact ? 20 : 26);

    return Semantics(
      button: true,
      selected: selected,
      child: GlassSurface(
        borderRadius: radius,
        blur: compact ? AppGlass.blurChip : AppGlass.blurCard,
        isAccented: selected,
        onTap: onTap,
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 14)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: compact
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      mode.title.s(14).w(600).c(foreground),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: (selected ? accent : context.textSecondary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: icon,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            mode.title.s(15).w(600).c(foreground).copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            mode.description.s(12).w(400).c(context.textSecondary).copyWith(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
