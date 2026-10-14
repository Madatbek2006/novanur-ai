import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurnova_ai/core/enum/describe_img_type.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/domain/models/dashboard/dashboard_button_data.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/app_camera_controller.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/app_camera_view.dart';
import 'package:nurnova_ai/presentation/router/app_router.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_statefull_page.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';
import 'package:nurnova_ai/presentation/widgets/action/dashboard_button.dart';

import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/core/gen/localization/strings_locale_keys.g.dart';
import 'package:nurnova_ai/core/objects/home_objects.dart';
import 'package:nurnova_ai/core/objects/object_labels.dart';
import 'package:nurnova_ai/presentation/widgets/speech/speech_control.dart';

import 'dashboard_cubit.dart';
import 'find_object_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

@RoutePage()
class DashboardPage
    extends BaseStatefulPage<DashboardCubit, DashboardState, DashboardEvent> {
  const DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends BaseStatefulPageState<DashboardPage,
    DashboardCubit, DashboardState, DashboardEvent> {
  /// The app's only camera. Mode switches change what it analyses, never which
  /// camera is open.
  late final AppCameraController _camera;

  /// Названия предметов на языках приложения. Пока словарь грузится,
  /// подписи остаются английскими.
  ObjectLabels _labels = ObjectLabels.english;

  @override
  void onWidgetCreated() {
    ObjectLabels.load().then((labels) {
      if (mounted) setState(() => _labels = labels);
    });
    _camera = AppCameraController(
      onBarcode: (value) {
        // Отклик в руку сразу, ещё до поиска товара: пользователь должен
        // знать, что код пойман, и не водить камерой дальше.
        HapticFeedback.mediumImpact();
        cubit().onBarcode(value, context.locale.languageCode);
      },
    );
    _camera.addListener(_onCameraChanged);
    _camera.initialize(analysis: _analysisFor(cubit().states.type));
  }

  /// Самая конкретная метка предмета — на языке приложения.
  String? _describe(DetectedObject object) {
    final label = ObjectLabels.pickLabel([
      for (final l in object.labels) (l.text, l.confidence),
    ]);
    return label == null
        ? null
        : _labels.translate(label, context.locale.languageCode);
  }

  /// Каждый проанализированный кадр в режимах предметов уходит в куб: он
  /// решает, что показать в карточке и что назвать вслух.
  void _onCameraChanged() {
    if (!mounted) return;
    if (_camera.analysis != CameraAnalysis.objectDetection &&
        _camera.analysis != CameraAnalysis.homeObjects) {
      return;
    }
    if (cubit().states.type == DashboardButtonType.findObject) {
      final inView = _camera.objects.any(_isFindTarget);
      if (inView) _pulse();
      cubit().onFindFrame(inView, context.locale.languageCode);
      return;
    }
    cubit().onObjectsInView(
      _camera.objects.map(_describe).nonNulls.toList(),
      context.locale.languageCode,
    );
  }

  /// Тот ли это предмет, что ищем. Детектор даёт предмету несколько меток —
  /// «мебель», «полка», «книжный шкаф», — искомая может быть любой из них.
  /// Сравниваем по названию: у «Eyewear» и «Glasses» оно одно — «очки».
  bool _isFindTarget(DetectedObject object) {
    final name = cubit().states.findTargetName;
    if (name == null) return false;
    final language = context.locale.languageCode;
    return object.labels.any((l) => _labels.translate(l.text, language) == name);
  }

  /// Пока искомое в кадре — толчок в руку раз в полсекунды: можно навестись
  /// точнее, не дожидаясь голоса.
  DateTime _lastPulse = DateTime(0);

  void _pulse() {
    final now = DateTime.now();
    if (now.difference(_lastPulse) < const Duration(milliseconds: 500)) return;
    _lastPulse = now;
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _camera.removeListener(_onCameraChanged);
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget onWidgetBuild(BuildContext context, DashboardState state) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: _backgroundGradient(context)),
        child: Stack(
          children: [
            Positioned.fill(
              child: AppCameraView(
                controller: _camera,
                // При поиске рамка только у искомого и подписана его именем.
                describeObject: state.type == DashboardButtonType.findObject
                    ? (_) => state.findTargetName
                    : _describe,
                showObject: state.type == DashboardButtonType.findObject
                    ? _isFindTarget
                    : null,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewPaddingOf(context).bottom + 80,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.type == DashboardButtonType.scanBarcode)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _BarcodeCard(
                          state: state,
                          cubit: cubit(),
                        ),
                      ),
                    if (state.type == DashboardButtonType.objectRecognition ||
                        state.type == DashboardButtonType.homeObjects)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _ObjectsCard(
                          state: state,
                          cubit: cubit(),
                        ),
                      ),
                    if (state.type == DashboardButtonType.findObject)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _FindCard(
                          state: state,
                          onChoose: _chooseFindTarget,
                        ),
                      ),
                    _buildModeSelector(context, state),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------- modes

  Widget _buildModeSelector(BuildContext context, DashboardState state) {
    return SizedBox(
      height: 128,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: DashboardButtonType.values
              .map(
                (type) => DashboardButton(
                  isClicked: state.type == type,
                  data: type,
                  onPressed: _onModePressed,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  /// First tap selects a mode, a second tap on the selected mode runs it.
  void _onModePressed(DashboardButtonType type) {
    if (cubit().states.type != type) {
      HapticFeedback.selectionClick();
      cubit().setDashboardButtonType(type);
      _camera.setAnalysis(_analysisFor(type));
      // Поиск начинается с вопроса, что искать.
      if (type == DashboardButtonType.findObject) _chooseFindTarget();
      return;
    }
    _runAction(type);
  }

  CameraAnalysis _analysisFor(DashboardButtonType? type) {
    switch (type) {
      case DashboardButtonType.objectRecognition:
        return CameraAnalysis.objectDetection;
      case DashboardButtonType.homeObjects:
        return CameraAnalysis.homeObjects;
      case DashboardButtonType.findObject:
        // Мебель лучше видит своя модель, всё остальное — ML Kit.
        final target = cubit().states.findTarget;
        if (target == null) return CameraAnalysis.none;
        return homeObjectNames.contains(target)
            ? CameraAnalysis.homeObjects
            : CameraAnalysis.objectDetection;
      case DashboardButtonType.scanBarcode:
        return CameraAnalysis.barcode;
      case DashboardButtonType.scanText:
      case DashboardButtonType.describeScene:
      case null:
        return CameraAnalysis.none;
    }
  }

  void _runAction(DashboardButtonType type) {
    switch (type) {
      case DashboardButtonType.scanText:
        _scanText();
        break;
      case DashboardButtonType.describeScene:
        _showDescribeOptions();
        break;
      // Живые режимы называют находки сами; второе нажатие — переспросить.
      case DashboardButtonType.scanBarcode:
        cubit().repeatBarcode();
        break;
      case DashboardButtonType.objectRecognition:
      case DashboardButtonType.homeObjects:
        cubit().readObjectsInView();
        break;
      case DashboardButtonType.findObject:
        _chooseFindTarget();
        break;
    }
  }

  // ----------------------------------------------------------------- actions

  Future<void> _scanText() async {
    HapticFeedback.heavyImpact();
    cubit().stopSpeaking();
    final photo = await _camera.takePicture(compress: false);
    if (photo == null) return;

    cubit().setTakenPhoto(photo);
    await _camera.setFlash(FlashMode.off);
    if (!mounted) return;

    context.router.push(ScanTextRoute(photo: photo));
  }

  Future<void> _describeScene(DescribeImgType type) async {
    HapticFeedback.heavyImpact();
    cubit().stopSpeaking();
    final photo = await _camera.takePicture();
    if (photo == null) return;

    cubit().setTakenPhoto(photo);
    await _camera.setFlash(FlashMode.off);
    if (!mounted) return;

    context.router.push(ChatRoute(photoFile: photo, type: type));
  }

  /// Спрашивает, что искать, и начинает поиск. Передумали — режим ждёт
  /// следующего нажатия.
  Future<void> _chooseFindTarget() async {
    HapticFeedback.lightImpact();
    cubit().stopSpeaking();
    final language = context.locale.languageCode;
    final label = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => FindObjectDialog(
        labels: _labels,
        languageCode: language,
        onSay: (text) => cubit().announce(text, language),
      ),
    );
    if (!mounted ||
        label == null ||
        cubit().states.type != DashboardButtonType.findObject) {
      return;
    }
    cubit().setFindTarget(label, _labels.translate(label, language), language);
    _camera.setAnalysis(_analysisFor(DashboardButtonType.findObject));
  }

  void _showDescribeOptions() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) => _DescribeOptionsDialog(
        onSelected: (type) {
          Navigator.of(dialogContext).pop();
          _describeScene(type);
        },
      ),
    );
  }

  Gradient _backgroundGradient(BuildContext context) {
    final dark = context.isDarkMode;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: dark
          ? const [Color(0xFF0D1117), Color(0xFF161B27), Color(0xFF0A0E1A)]
          : const [Color(0xFFEEF2FF), Color(0xFFE1EAFF), Color(0xFFF0F4FF)],
    );
  }
}

/// Frosted-glass picker for the "describe scene" prompt variants.
class _DescribeOptionsDialog extends StatelessWidget {
  const _DescribeOptionsDialog({required this.onSelected});

  final void Function(DescribeImgType type) onSelected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: GlassSurface(
        blur: AppGlass.blurPanel,
        borderRadius: AppGlass.panelAll,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: DescribeImgType.values
              .map(
                (type) => _GlassOption(
                  title: type.title,
                  onTap: () => onSelected(type),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _GlassOption extends StatelessWidget {
  const _GlassOption({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GlassSurface(
        blur: AppGlass.blurChip,
        borderRadius: AppGlass.chipAll,
        hasShadow: false,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: title.s(15).w(500),
        ),
      ),
    );
  }
}

/// Что камера поймала в режиме штрихкода: название товара, текст кода или
/// честное сообщение — и тот же плеер, что во всех остальных разделах.
class _BarcodeCard extends StatelessWidget {
  const _BarcodeCard({required this.state, required this.cubit});

  final DashboardState state;
  final DashboardCubit cubit;

  @override
  Widget build(BuildContext context) {
    final text = state.barcodeText;
    final canPlay = text != null &&
        (state.barcodeLookup == BarcodeLookup.product ||
            state.barcodeLookup == BarcodeLookup.text);

    return GlassSurface(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (state.barcodeLookup == BarcodeLookup.searching) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: _title.s(16).w(600).c(context.textPrimary).copyWith(
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
              ],
            ),
            if (state.barcode != null &&
                state.barcodeLookup != BarcodeLookup.text) ...[
              const SizedBox(height: 4),
              state.barcode!.s(12).w(500).c(context.textSecondary),
            ],
            if (canPlay) ...[
              const SizedBox(height: 8),
              SpeechControl(
                speechId: cubit.speechIdFor(text),
                playback: state.playback,
                clips: state.speechClips,
                positionStream: cubit.speechPositionStream,
                onToggle: () => cubit.toggleSpeech(text),
                onSeek: cubit.seekSpeech,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _title => switch (state.barcodeLookup) {
        BarcodeLookup.waiting => Strings.webBarcodeCameraHint,
        BarcodeLookup.searching => Strings.webProductLoading,
        BarcodeLookup.product ||
        BarcodeLookup.text ||
        BarcodeLookup.notFound ||
        BarcodeLookup.failed =>
          state.barcodeText ?? '',
      };
}

/// Что сейчас в кадре в режимах предметов. Новые предметы называются сами;
/// плеер и второе нажатие на режим перечисляют всё, что видно.
class _ObjectsCard extends StatelessWidget {
  const _ObjectsCard({required this.state, required this.cubit});

  final DashboardState state;
  final DashboardCubit cubit;

  @override
  Widget build(BuildContext context) {
    final summary = cubit.objectsSummary;

    return GlassSurface(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            (summary.isEmpty ? cubit.objectsHint : summary)
                .s(16)
                .w(600)
                .c(context.textPrimary)
                .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 8),
              SpeechControl(
                speechId: cubit.speechIdFor(summary),
                playback: state.playback,
                clips: state.speechClips,
                positionStream: cubit.speechPositionStream,
                onToggle: () => cubit.toggleSpeech(summary),
                onSeek: cubit.seekSpeech,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Режим поиска: что ищем и видно ли оно. Нажатие — выбрать другой предмет.
class _FindCard extends StatelessWidget {
  const _FindCard({required this.state, required this.onChoose});

  final DashboardState state;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final name = state.findTargetName;
    final found = name != null && state.findTargetInView;
    final text = name == null
        ? Strings.findObjectChoose
        : found
            ? LocaleKeys.findObjectInView.tr(args: [name])
            : LocaleKeys.findObjectSearching.tr(args: [name]);

    return GlassSurface(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      isAccented: found,
      onTap: onChoose,
      child: Semantics(
        liveRegion: true,
        button: true,
        child: Row(
          children: [
            if (found)
              Icon(Icons.check_circle_rounded, color: context.primaryLight)
            else if (name != null)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            if (name != null) const SizedBox(width: 10),
            Expanded(
              child: text.s(16).w(600).c(context.textPrimary).copyWith(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
