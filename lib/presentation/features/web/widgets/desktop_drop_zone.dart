import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:nurnova_ai/utils/web/browser_vision.dart';
import 'package:pasteboard/pasteboard.dart';

/// Перетаскивание картинки в окно и вставка Ctrl+V — в десктопной версии.
/// В браузере это ловит сам сайт (nurnova_vision.js); здесь — Flutter, и
/// передаёт в те же обработчики экрана через [BrowserVision].
class DesktopDropZone extends StatefulWidget {
  const DesktopDropZone({super.key, required this.child});

  final Widget child;

  @override
  State<DesktopDropZone> createState() => _DesktopDropZoneState();
}

class _DesktopDropZoneState extends State<DesktopDropZone> {
  @override
  void initState() {
    super.initState();
    // Глобально, а не через Focus: вставка должна работать, даже когда
    // фокус ни на чём не стоит.
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    final keyboard = HardwareKeyboard.instance;
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.keyV ||
        !(keyboard.isControlPressed || keyboard.isMetaPressed)) {
      return false;
    }
    // В текстовом поле Ctrl+V вставляет текст — не мешаем.
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused?.findAncestorWidgetOfExactType<EditableText>() != null ||
        focused?.widget is EditableText) {
      return false;
    }
    _pasteImage();
    return false;
  }

  Future<void> _pasteImage() async {
    try {
      final bytes = await Pasteboard.image;
      if (bytes == null || bytes.isEmpty) return;
      BrowserVision.handleDrop(
        PickedFileData(name: 'pasted.png', type: 'image/png', bytes: bytes),
      );
    } catch (e) {
      Logger().w('DesktopDropZone: картинку из буфера не взять: $e');
    }
  }

  Future<void> _onDropped(DropDoneDetails details) async {
    BrowserVision.handleDragChange(false);
    if (details.files.isEmpty) return;
    final file = details.files.first;
    BrowserVision.handleDrop(PickedFileData(
      name: file.name,
      type: file.mimeType ?? imageMimeType(file.name),
      bytes: await file.readAsBytes(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => BrowserVision.handleDragChange(true),
      onDragExited: (_) => BrowserVision.handleDragChange(false),
      onDragDone: _onDropped,
      child: widget.child,
    );
  }
}
