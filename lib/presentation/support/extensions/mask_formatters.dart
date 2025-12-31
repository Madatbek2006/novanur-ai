import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

var phoneMaskFormatter = MaskTextInputFormatter(
  mask: '__ ___ __ __',
  filter: {"_": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

var birthDateMaskFormatter = MaskTextInputFormatter(
  mask: '____-__-__',
  filter: {"_": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

var docNumberMaskFormatter = MaskTextInputFormatter(
  mask: '___ __ __',
  filter: {"_": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

var cardNumberMaskFormatter = MaskTextInputFormatter(
  mask: '____ ____ ____ ____',
  filter: {"_": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

var cardExpiredMaskFormatter = MaskTextInputFormatter(
  mask: '__/__',
  filter: {"_": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

var priceMaskFormatter = CurrencyTextInputFormatter.new;

var quantityMaskFormatter = CurrencyTextInputFormatter.new;

extension CurrencyTextInputFormatterMethodExts on CurrencyTextInputFormatter {
  String? formatInt(int? value) {
    return value == null ? null : formatDouble(value.toDouble());
  }
}

extension MaskTextInputFormatterMethodExts on MaskTextInputFormatter {
  String? formatInt(int? value) {
    return value == null ? null : maskText(value.toString());
  }

  String? formatDouble(double? value) {
    return value == null ? null : maskText(value.toString());
  }

  String? formatString(String? value) {
    return value == null ? null : maskText(value);
  }
}
