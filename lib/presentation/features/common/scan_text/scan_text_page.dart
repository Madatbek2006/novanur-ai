import 'package:auto_route/auto_route.dart';
import 'package:nurnova_ai/core/enum/enums.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_statefull_page.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/widgets/app_bar/default_app_bar.dart';
import 'package:nurnova_ai/presentation/widgets/dialog/progress_dialog.dart';
import 'package:nurnova_ai/presentation/widgets/speech/speech_control.dart';
import 'package:nurnova_ai/presentation/widgets/state/loader_state_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import 'scan_text_cubit.dart';

@RoutePage()
class ScanTextPage
    extends BaseStatefulPage<ScanTextCubit, ScanTextState, ScanTextEvent> {
  ScanTextPage(this.photo, {super.key});
  final XFile photo;



  @override
  State<StatefulWidget> createState() => ScanTextPageState();
}

class ScanTextPageState extends BaseStatefulPageState<ScanTextPage, ScanTextCubit, ScanTextState, ScanTextEvent>{
  String recognizedText = '';
  LoadingState loadingState = LoadingState.loading;

  @override
  void onWidgetCreated() {
    // cubit().setInitialData();
    recognize();
  }
  @override
  void onEventEmitted(ScanTextEvent event) {
    switch(event.type){

      case ScanTextEventType.showProgressDialog:
        ProgressDialog.show(context);
      case ScanTextEventType.hideProgressDialog:
        ProgressDialog.hide(context);
      case ScanTextEventType.closePage:
        context.router.popForced();

    }
  }


  @override
  Widget onWidgetBuild(BuildContext context, ScanTextState state) {
    return Scaffold(
      // backgroundColor: context.mainBg,
      appBar: DefaultAppBar(
        onBackPressed: (){
          context.router.popForced();
        },titleText: Strings.dashboardButtonTypeScanText,
      ),
      body: _buildBody(context, state),
    );
  }

  Future<void> recognize() async {
    final inputImage = InputImage.fromFilePath(widget.photo.path);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText result =
    await textRecognizer.processImage(inputImage);

    String text = '';
    for (final block in result.blocks) {
      for (final line in block.lines) {
        text += line.text + '\n';
      }
    }
    Logger().d("TTT=>text: $text");
    textRecognizer.close();
    if (!mounted) return;

    final cleaned = text.trim();
    setState(() {
      recognizedText = cleaned;
      loadingState=cleaned.isNotEmpty?LoadingState.success:LoadingState.empty;
    });

    // Тем же голосом и на том же языке, что и ответ в чате.
    final language = context.locale.languageCode;
    if (cleaned.isEmpty) {
      cubit().announce(Strings.scanTextEmpty, language);
    } else {
      cubit().read(cleaned, language);
    }
  }

  Widget _buildBody(BuildContext context, ScanTextState state) {
    return LoaderStateWidget(
        loadingState: loadingState,
        loadingBody: _buildLoading(),
        successBody: _buildSuccess(state),
        emptyBody: _buildEmpty(),
    );
  }

  Widget _buildLoading(){
      return const Center(
        child: CircularProgressIndicator(),
      );
  }
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          Strings.scanTextEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: context.textSecondary),
        ),
      ),
    );
  }

  Widget _buildSuccess(ScanTextState state){
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              recognizedText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600, // если .w(600) — это semi-bold
                color: context.textPrimary,
              ),
            ),
          ),
        ),
        // Плеер под текстом и всегда на виду, даже когда текст длинный и
        // прокручен: та же полоса, что под ответом в чате.
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SpeechControl(
              speechId: cubit().speechIdFor(recognizedText),
              playback: state.playback,
              clips: state.speechClips,
              positionStream: cubit().speechPositionStream,
              onToggle: () => cubit().toggleSpeech(recognizedText),
              onSeek: cubit().seekSpeech,
            ),
          ),
        ),
      ],
    );
  }
}
