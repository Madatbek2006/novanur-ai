import 'package:baiqavisit/core/stream/base_stream_controller.dart';
import 'package:baiqavisit/domain/models/login/login_event.dart';

class LoginEventStreamController extends BaseStreamController<LoginEvent> {
  LoginEventStreamController({super.isBroadcast = true});
}
