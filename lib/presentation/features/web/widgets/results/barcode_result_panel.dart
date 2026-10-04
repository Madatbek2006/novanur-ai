import 'package:baiqavisit/core/enum/enums.dart';
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/data/datasource/network/dto/barcode/product_response.dart';
import 'package:baiqavisit/presentation/features/web/dashboard/web_dashboard_cubit.dart';
import 'package:baiqavisit/presentation/features/web/widgets/results/speak_button.dart';
import 'package:baiqavisit/presentation/features/web/widgets/web_ui.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/utils/web/browser_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BarcodeResultPanel extends StatelessWidget {
  const BarcodeResultPanel({super.key, required this.state, required this.cubit});

  final WebDashboardState state;
  final WebDashboardCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildBody(context)),
        const SizedBox(height: 12),
        _ManualEntry(onSearch: cubit.searchBarcode),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final barcode = state.barcode;
    if (state.barcodeState == LoadingState.loading) {
      return WebProgress(text: Strings.webBarcodeSearching);
    }
    if (state.barcodeState == LoadingState.error) {
      return WebError(text: Strings.webAnalysisError, onRetry: cubit.retry);
    }
    if (barcode == null) {
      if (state.isCameraOn) {
        return WebHint(icon: Icons.qr_code_scanner, text: Strings.webBarcodeCameraHint);
      }
      if (state.barcodeState == LoadingState.empty) {
        return WebHint(icon: Icons.search_off, text: Strings.webBarcodeNotFound);
      }
      return WebHint(icon: Icons.qr_code_2, text: Strings.webBarcodeIdleHint);
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CodeCard(barcode: barcode),
          const SizedBox(height: 16),
          _buildProduct(context, barcode),
        ],
      ),
    );
  }

  Widget _buildProduct(BuildContext context, VisionBarcode barcode) {
    if (!barcode.isProductCode) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SpeakButton(
            isSpeaking: state.isSpeaking,
            onSpeak: () => cubit.speak(barcode.text),
            onStop: cubit.stopSpeaking,
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: barcode.text));
              cubit.textCopied();
            },
            icon: const Icon(Icons.copy_rounded),
            label: Text(Strings.webCopy),
          ),
          if (Uri.tryParse(barcode.text)?.hasScheme == true)
            OutlinedButton.icon(
              onPressed: () => launchUrl(Uri.parse(barcode.text)),
              icon: const Icon(Icons.open_in_new),
              label: Text(Strings.webOpenLink),
            ),
        ],
      );
    }
    return switch (state.productState) {
      LoadingState.initial || LoadingState.loading => Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: WebProgress(text: Strings.webProductLoading),
        ),
      LoadingState.error => WebError(
          text: Strings.messageConnectionError,
          onRetry: () => cubit.searchBarcode(barcode.text),
        ),
      LoadingState.empty => WebNotice(
          text: Strings.webProductNotFound,
          icon: Icons.help_outline,
          color: Colors.orange,
        ),
      LoadingState.success => _ProductCard(
          product: state.product!,
          barcode: barcode.text,
          isSpeaking: state.isSpeaking,
          onSpeak: () => cubit.speak(state.product?.productName ?? ''),
          onStop: cubit.stopSpeaking,
        ),
    };
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.barcode});

  final VisionBarcode barcode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.mainBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code_2, color: context.colors.buttonPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Strings.webBarcodeCode.s(12).w(500).c(context.textSecondary),
                const SizedBox(height: 2),
                SelectionArea(
                  child: Text(
                    barcode.text,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (barcode.format.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: context.borderStroke),
                borderRadius: BorderRadius.circular(6),
              ),
              child: barcode.format.toUpperCase().replaceAll('_', '-').s(11).w(600).c(context.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.barcode,
    required this.isSpeaking,
    required this.onSpeak,
    required this.onStop,
  });

  final ProductResponse product;
  final String barcode;
  final bool isSpeaking;
  final VoidCallback onSpeak;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final image = product.imageUrl;
    final details = <(String, String?)>[
      (Strings.webProductBrand, product.brands),
      (Strings.commonQuantity, product.quantity),
      (Strings.webProductIngredients, product.ingredientsText),
    ].where((e) => e.$2 != null && e.$2!.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null && image.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  image,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  // Shows the photo even if the image host sends no CORS headers.
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder: (_, __, ___) => const SizedBox(width: 88, height: 88),
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Semantics(
                header: true,
                child: (product.productName ?? '').s(18).w(700).c(context.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final (label, value) in details) ...[
          label.s(12).w(500).c(context.textSecondary),
          const SizedBox(height: 2),
          value!.trim().s(14).w(500).c(context.textPrimary).copyWith(maxLines: 6, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SpeakButton(isSpeaking: isSpeaking, onSpeak: onSpeak, onStop: onStop),
            OutlinedButton.icon(
              onPressed: () => launchUrl(Uri.parse('https://world.openfoodfacts.org/product/$barcode')),
              icon: const Icon(Icons.open_in_new),
              label: Text(Strings.webProductOpen),
            ),
          ],
        ),
      ],
    );
  }
}

class _ManualEntry extends StatefulWidget {
  const _ManualEntry({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  State<_ManualEntry> createState() => _ManualEntryState();
}

class _ManualEntryState extends State<_ManualEntry> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSearch(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.search,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              isDense: true,
              labelText: Strings.webBarcodeManualHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.buttonPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(Strings.webBarcodeSearch),
        ),
      ],
    );
  }
}
