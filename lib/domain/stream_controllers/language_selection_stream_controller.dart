import 'package:nurnova_ai/core/stream/base_stream_controller.dart';
import 'package:nurnova_ai/domain/models/language/language.dart';

class LanguageSelectionStreamController extends BaseStreamController<Language> {
  LanguageSelectionStreamController({super.isBroadcast = true});
}
