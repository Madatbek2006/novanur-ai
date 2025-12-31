import 'package:baiqavisit/core/stream/base_stream_controller.dart';
import 'package:baiqavisit/domain/models/language/language.dart';

class LanguageSelectionStreamController extends BaseStreamController<Language> {
  LanguageSelectionStreamController({super.isBroadcast = true});
}
