import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:nurnova_ai/presentation/application/di/get_it_injection.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_state.dart';
import 'package:nurnova_ai/presentation/support/state_message/state_message_manager.dart';

abstract class BaseCubit<STATE, EVENT> extends Cubit<BaseState<STATE, EVENT>> {
  late STATE states;

  final logger = getIt<Logger>();
  final stateMessageManager = getIt<StateMessageManager>();

  BaseCubit(STATE initialState) : super(BaseState(state: initialState)) {
    states = initialState;
  }

  updateState(STATE Function(STATE state) updateState) {
    states = updateState(states);
    emit(BaseState(state: states));
  }

  emitEvent(EVENT event) {
    emit(BaseState(event: event));
    updateState((state) => states);
  }
}
