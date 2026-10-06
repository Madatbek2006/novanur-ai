import 'package:auto_route/auto_route.dart';
import 'package:nurnova_ai/core/enum/enums.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/domain/models/dashboard/dashboard_button_data.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/browser_camera_view.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/image_source_panel.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/mode_selector.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/results/barcode_result_panel.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/results/describe_panel.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/results/objects_result_panel.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/results/text_result_panel.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/web_ui.dart';
import 'package:nurnova_ai/presentation/router/app_router.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_statefull_page.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/utils/web/browser_vision.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'web_dashboard_cubit.dart';

/// The dashboard of the web build. Same four tools as the phone app, but any
/// image works as input: camera, file picker, drag-and-drop or paste.
@RoutePage()
class WebDashboardPage
    extends BaseStatefulPage<WebDashboardCubit, WebDashboardState, WebDashboardEvent> {
  const WebDashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _WebDashboardPageState();
}

class _WebDashboardPageState extends BaseStatefulPageState<WebDashboardPage,
    WebDashboardCubit, WebDashboardState, WebDashboardEvent> {
  final _camera = BrowserCameraController();
  TabsRouter? _tabsRouter;
  bool _isActiveTab = true;
  Locale? _locale;

  @override
  void onWidgetCreated() {
    _listenForFiles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.locale;
    if (_locale == null) {
      cubit().init(locale);
    } else if (locale != _locale) {
      cubit().setLocale(locale);
    }
    _locale = locale;

    final tabsRouter = context.tabsRouter;
    if (tabsRouter != _tabsRouter) {
      _tabsRouter?.removeListener(_onTabChanged);
      _tabsRouter = tabsRouter..addListener(_onTabChanged);
    }
  }

  @override
  void dispose() {
    _tabsRouter?.removeListener(_onTabChanged);
    BrowserVision.clearDropHandler();
    super.dispose();
  }

  void _listenForFiles() => BrowserVision.setDropHandler(cubit().openFile, cubit().setDragging);

  // Tabs stay alive in the background, so the camera and the drop target
  // follow the tab's visibility.
  void _onTabChanged() {
    final active = _tabsRouter?.current.name == WebDashboardRoute.name;
    if (active == _isActiveTab) return;
    _isActiveTab = active;
    if (active) {
      _listenForFiles();
      cubit().resume();
    } else {
      BrowserVision.clearDropHandler();
      cubit().pause();
    }
  }

  @override
  void onEventEmitted(WebDashboardEvent event) {
    switch (event.type) {
      case WebDashboardEventType.textCopied:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Strings.webCopied),
            behavior: SnackBarBehavior.floating,
            width: 280,
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  Future<void> _chooseImage() async {
    final file = await BrowserVision.pickImage();
    if (file != null) await cubit().openFile(file);
  }

  Future<void> _capture() async {
    final image = await _camera.capture();
    if (image != null) cubit().setImage(image);
  }

  @override
  Widget onWidgetBuild(BuildContext context, WebDashboardState state) {
    return Scaffold(
      backgroundColor: context.backgroundGreyColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= WebBreakpoints.wide
              ? _buildWide(context, state, constraints)
              : _buildNarrow(context, state, constraints),
        ),
      ),
    );
  }

  Widget _buildWide(BuildContext context, WebDashboardState state, BoxConstraints constraints) {
    final resultWidth = (constraints.maxWidth * 0.34).clamp(360.0, 480.0);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModeSelector(selected: state.mode, onSelected: cubit().selectMode, compact: false),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildSourcePanel(state)),
                    const SizedBox(width: 20),
                    SizedBox(width: resultWidth, child: _buildResultPanel(context, state)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNarrow(BuildContext context, WebDashboardState state, BoxConstraints constraints) {
    final height = constraints.maxHeight;
    return ListView(
      // Leaves room for the floating bottom navigation.
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.viewPaddingOf(context).bottom + 104),
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Assets.images.logo.appLogo.image(width: 32, height: 32),
            ),
            const SizedBox(width: 10),
            "NurNova AI".s(18).w(700).c(context.textPrimary),
          ],
        ),
        const SizedBox(height: 12),
        ModeSelector(selected: state.mode, onSelected: cubit().selectMode, compact: true),
        const SizedBox(height: 12),
        SizedBox(height: (height * 0.55).clamp(300.0, 560.0), child: _buildSourcePanel(state)),
        const SizedBox(height: 12),
        SizedBox(height: (height * 0.6).clamp(380.0, 620.0), child: _buildResultPanel(context, state)),
      ],
    );
  }

  Widget _buildSourcePanel(WebDashboardState state) {
    final mode = state.mode;
    return ImageSourcePanel(
      cameraView: BrowserCameraView(
        controller: _camera,
        front: state.isFrontCamera,
        liveTask: _liveTask(state),
        onStarted: cubit().cameraStarted,
        onBarcode: cubit().onLiveBarcode,
        onObjects: cubit().onLiveObjects,
        onLiveError: cubit().onLiveError,
      ),
      isCameraOn: state.isCameraOn,
      image: state.image,
      objects: mode == DashboardButtonType.objectRecognition ? state.objects : VisionObjects.empty,
      nameOf: state.objectName,
      cameraStatus: state.cameraStatus,
      cameraCount: state.cameraCount,
      liveHint: switch (mode) {
        DashboardButtonType.scanBarcode => Strings.webBarcodeCameraHint,
        DashboardButtonType.objectRecognition => Strings.webObjectsCameraHint,
        DashboardButtonType.scanText => Strings.webTextCameraHint,
        DashboardButtonType.describeScene => Strings.webDescribeCameraHint,
      },
      isDragging: state.isDragging,
      isOpeningImage: state.isOpeningImage,
      error: state.sourceError,
      cameraNote: _cameraNote(state.cameraStatus),
      onDismissError: cubit().clearSourceError,
      onChooseImage: _chooseImage,
      onUseCamera: cubit().useCamera,
      onStopCamera: cubit().stopCamera,
      onSwitchCamera: cubit().switchCamera,
      onCapture: _capture,
      onRemoveImage: cubit().removeImage,
    );
  }

  /// Explains up front why the camera button is off.
  String? _cameraNote(BrowserCameraStatus status) => switch (status) {
        BrowserCameraStatus.none => Strings.webCameraNoDevice,
        BrowserCameraStatus.insecure => Strings.webCameraInsecure,
        BrowserCameraStatus.unsupported => Strings.webCameraUnsupported,
        _ => null,
      };

  LiveTask _liveTask(WebDashboardState state) {
    if (!state.isCameraOn) return LiveTask.none;
    return switch (state.mode) {
      DashboardButtonType.scanBarcode =>
        state.barcodeState == LoadingState.error ? LiveTask.none : LiveTask.barcode,
      DashboardButtonType.objectRecognition =>
        state.objectsState == LoadingState.error ? LiveTask.none : LiveTask.objects,
      _ => LiveTask.none,
    };
  }

  Widget _buildResultPanel(BuildContext context, WebDashboardState state) {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: state.mode.title.s(18).w(700).c(context.textPrimary),
          ),
          const SizedBox(height: 4),
          state.mode.description.s(13).w(400).c(context.textSecondary),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // All four stay built, so e.g. the chat survives a look at another tool.
                IndexedStack(
                  index: state.mode.index,
                  sizing: StackFit.expand,
                  children: [
                    for (final mode in DashboardButtonType.values)
                      switch (mode) {
                        DashboardButtonType.scanText => TextResultPanel(state: state, cubit: cubit()),
                        DashboardButtonType.scanBarcode => BarcodeResultPanel(state: state, cubit: cubit()),
                        DashboardButtonType.describeScene => DescribePanel(state: state, cubit: cubit()),
                        DashboardButtonType.objectRecognition => ObjectsResultPanel(state: state, cubit: cubit()),
                      },
                  ],
                ),
                // Results still belong to the previous image until the new one is ready.
                if (state.isOpeningImage)
                  ColoredBox(
                    color: context.cardColor.withValues(alpha: 0.85),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
