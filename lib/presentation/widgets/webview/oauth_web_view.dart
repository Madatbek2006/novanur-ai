import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:nurnova_ai/core/enum/enums.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/widgets/state/default_error_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OAuthWebView extends StatefulWidget {
  final String initialUrl;
  final String redirectUrl;
  final Function(int) onProcess;
  final Function(String) onPageStarted;
  final Function(String) onPageFinished;
  final Function(String) onRedirectUrlHandled;
  final Function(WebResourceError) onFailed;

  const OAuthWebView({
    super.key,
    required this.initialUrl,
    required this.redirectUrl,
    required this.onPageStarted,
    required this.onProcess,
    required this.onPageFinished,
    required this.onRedirectUrlHandled,
    required this.onFailed,
  });

  @override
  State<OAuthWebView> createState() => _OAuthWebViewState();
}

class _OAuthWebViewState extends State<OAuthWebView>
    with AutomaticKeepAliveClientMixin {
  late final WebViewController _webViewController;
  LoadingState loadingState = LoadingState.initial;

  @override
  bool get wantKeepAlive => true;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Logger().e("OAuthWebView initState");
    _focusNode.addListener(_onFocusChange);

    _webViewController = WebViewController()
      ..clearCache()
      ..clearLocalStorage()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(widget.initialUrl))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            // Logger().e("OAuthWebView onProgress progress = $progress");
            widget.onProcess(progress);
            setState(() => loadingState = LoadingState.loading);
          },
          onPageStarted: (url) {
            // Logger().e("OAuthWebView onPageStarted url = $url");
            widget.onPageStarted(url);
            setState(() => loadingState = LoadingState.loading);
          },
          onPageFinished: (url) {
            // Logger().e("OAuthWebView onPageFinished url = $url");
            widget.onPageFinished(url);
            setState(() => loadingState = LoadingState.success);
          },
          onWebResourceError: (error) {
            // Logger().e("OAuthWebView WebViewController error = $error");
            widget.onFailed(error);
            setState(() => loadingState = LoadingState.error);
          },
          onNavigationRequest: (request) {
            // Logger().e("OAuthWebView onNavigationRequest request = $request");
            if (request.url.startsWith(widget.redirectUrl)) {
              widget.onRedirectUrlHandled(request.url);
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        WebViewWidget(
          key: const PageStorageKey('oauth_web_view_key'),
          controller: _webViewController,
        ),
        Visibility(
          visible: loadingState == LoadingState.error,
          // visible: true,
          child: Container(
            color: context.backgroundWhiteColor,
            child: DefaultErrorWidget(
              isFullScreen: true,
              onRetryClicked: () {
                _webViewController.reload();
              },
            ),
          ),
        ),
      ],
    );
  }
}
