import 'package:nurnova_ai/core/stream/base_stream_controller.dart';
import 'package:nurnova_ai/domain/models/login/login_event.dart';

class LoginEventStreamController extends BaseStreamController<LoginEvent> {
  LoginEventStreamController({super.isBroadcast = true});
}
