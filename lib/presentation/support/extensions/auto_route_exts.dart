import 'package:auto_route/auto_route.dart';
import 'package:nurnova_ai/core/extensions/list_extensions.dart';
import 'package:nurnova_ai/presentation/router/app_router.dart';

extension AutoRouteExts on StackRouter {
  void popUntilOrPushHome(String routerName) {
    if (stack.containsIf((e) => e.name == routerName)) {
      popUntilRouteWithName(routerName);
    } else {
      replaceNamed(HomeRoute.name);
    }
  }
}
