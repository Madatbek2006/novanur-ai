import 'package:flutter/material.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/core/objects/object_labels.dart';
import 'package:nurnova_ai/core/objects/object_search.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';
import 'package:nurnova_ai/presentation/widgets/dialog/speech_to_text_dialog.dart';

/// Спрашивает, что искать: название можно написать или продиктовать, а можно
/// выбрать из списка предметов, которые узнаёт камера.
///
/// Возвращает имя предмета из словаря детектора или null, если передумали.
class FindObjectDialog extends StatefulWidget {
  const FindObjectDialog({
    super.key,
    required this.labels,
    required this.languageCode,
    required this.onSay,
  });

  final ObjectLabels labels;
  final String languageCode;

  /// Произнести вслух тем же голосом, что и всё приложение.
  final ValueChanged<String> onSay;

  @override
  State<FindObjectDialog> createState() => _FindObjectDialogState();
}

class _FindObjectDialogState extends State<FindObjectDialog> {
  final _query = TextEditingController();
  List<String> _matches = findSuggestions;
  bool _unknown = false;

  @override
  void initState() {
    super.initState();
    // Незрячий не видит, что открылось окно, — говорим, чего от него ждём.
    widget.onSay(Strings.findObjectTitle);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    setState(() {
      _unknown = false;
      _matches = text.trim().isEmpty
          ? findSuggestions
          : searchObjects(widget.labels, text, widget.languageCode);
    });
  }

  /// Ввод закончен — клавишей «Найти» или диктовкой: берём лучшее совпадение.
  void _submit(String text) {
    final matches = searchObjects(widget.labels, text, widget.languageCode);
    if (matches.isNotEmpty) {
      Navigator.of(context).pop(matches.first);
      return;
    }
    setState(() {
      _unknown = true;
      _matches = findSuggestions;
    });
    widget.onSay(Strings.findObjectUnknown);
  }

  Future<void> _dictate() async {
    String? heard;
    await showDialog<void>(
      context: context,
      builder: (_) => GoogleSpeechDialog(
        onResult: (text) {
          if (text.trim().isNotEmpty) heard = text;
        },
      ),
    );
    final text = heard;
    if (!mounted || text == null) return;
    _query.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _submit(text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: GlassSurface(
        blur: AppGlass.blurPanel,
        borderRadius: AppGlass.panelAll,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Strings.findObjectTitle.s(18).w(700).c(context.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _query,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: _onChanged,
                    onSubmitted: _submit,
                    style: TextStyle(fontSize: 16, color: context.textPrimary),
                    decoration: InputDecoration(
                      hintText: Strings.findObjectFieldHint,
                      hintStyle: TextStyle(color: context.textSecondary),
                      filled: true,
                      fillColor: context.textPrimary.withOpacity(0.06),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppGlass.chipAll,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: Strings.findObjectDictate,
                  child: GlassSurface(
                    width: 52,
                    height: 52,
                    blur: AppGlass.blurChip,
                    borderRadius: AppGlass.chipAll,
                    hasShadow: false,
                    onTap: _dictate,
                    child: Center(
                      child: Icon(Icons.mic_rounded, color: context.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
            if (_unknown) ...[
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Strings.findObjectUnknown.s(14).w(600).c(context.textPrimary),
              ),
            ],
            const SizedBox(height: 8),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    final label = _matches[index];
                    return _Option(
                      title: widget.labels.translate(label, widget.languageCode),
                      onTap: () => Navigator.of(context).pop(label),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GlassSurface(
        blur: AppGlass.blurChip,
        borderRadius: AppGlass.chipAll,
        hasShadow: false,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        child: SizedBox(
          width: double.infinity,
          child: title.s(15).w(500),
        ),
      ),
    );
  }
}
