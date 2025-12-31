import 'package:baiqavisit/core/stream/base_stream_controller.dart';
import 'package:baiqavisit/domain/models/identity/identity.dart';

class IdentityRefreshStreamController extends BaseStreamController<Identity> {
  IdentityRefreshStreamController({super.isBroadcast = true});
}
