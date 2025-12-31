import 'package:baiqavisit/core/enum/enums.dart';
import 'package:baiqavisit/presentation/support/cubit/base_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'scan_text_cubit.freezed.dart';
part 'scan_text_state.dart';

@injectable
class ScanTextCubit
    extends BaseCubit<ScanTextState, ScanTextEvent> {


  ScanTextCubit() : super(ScanTextState()) {
    _getInitialData();
  }

  _getInitialData() {

  }

  void reload() {
  }

}
