import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiqavisit/presentation/support/cubit/base_state.dart';

class BaseListener<CUBIT extends StateStreamable<BaseState<STATE, EVENT>>,
    STATE, EVENT> extends StatelessWidget {
  const BaseListener({
    super.key,
    required this.onEventEmitted,
    this.widget,
  });

  final Function(EVENT) onEventEmitted;
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CUBIT, BaseState<STATE, EVENT>>(
      listenWhen: (previous, current) {
        return current.event != null;
      },
      listener: (context, state) {
        onEventEmitted(state.event as EVENT);
      },
      child: widget,
    );
  }
}
