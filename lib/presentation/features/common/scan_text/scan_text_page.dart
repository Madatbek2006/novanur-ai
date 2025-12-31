import 'package:auto_route/auto_route.dart';
import 'package:baiqavisit/core/enum/enums.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/presentation/support/cubit/base_statefull_page.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/widgets/app_bar/default_app_bar.dart';
import 'package:baiqavisit/presentation/widgets/dialog/progress_dialog.dart';
import 'package:baiqavisit/presentation/widgets/state/loader_state_widget.dart';
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
    setState(() {
      recognizedText = text;
      loadingState=text.isNotEmpty?LoadingState.success:LoadingState.empty;
    });

    textRecognizer.close();
  }

  Widget _buildBody(BuildContext context, ScanTextState state) {
    return LoaderStateWidget(
        loadingState: loadingState,
        loadingBody: _buildLoading(),
        successBody: _buildSuccess()
    );
  }

  Widget _buildLoading(){
      return const Center(
        child: CircularProgressIndicator(),
      );
  }
  Widget _buildSuccess(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Text(
          recognizedText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600, // если .w(600) — это semi-bold
            color: context.textPrimary,
          ),
        ),
      ),
    );
  }
}
