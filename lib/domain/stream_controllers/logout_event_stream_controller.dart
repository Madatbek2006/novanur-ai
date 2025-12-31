import 'package:baiqavisit/core/stream/base_stream_controller.dart';
import 'package:baiqavisit/domain/models/logout/logout_event.dart';

class LogoutEventStreamController extends BaseStreamController<LogoutEvent> {
  LogoutEventStreamController({super.isBroadcast = true});
}
