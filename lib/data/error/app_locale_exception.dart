import 'package:nurnova_ai/data/error/app_exception.dart';

abstract class AppLocalException extends AppException {
  @override
  bool get isRequiredShowError => false;
}

class NotAuthorizedException implements AppLocalException {
  @override
  bool get isRequiredShowError => true;
}

class NotIdentifiedException implements AppLocalException {
  @override
  bool get isRequiredShowError => true;
}
