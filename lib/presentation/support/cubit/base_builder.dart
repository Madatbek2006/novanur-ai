import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_state.dart';

// ignore: must_be_immutable
class BaseBuilder<Cubit extends StateStreamable<BaseState<STATE, EVENT>>, STATE,
    EVENT> extends StatelessWidget {
  final List<dynamic> Function(STATE) properties;
  final bool Function(STATE)? onStateUpdated;
  final Widget Function(BuildContext context, STATE buildable) onWidgetBuild;

  BaseBuilder({
    Key? key,
    List<dynamic> Function(STATE)? properties,
    required this.onWidgetBuild,
    this.onStateUpdated,
  })  : properties = properties ?? ((state) => [state]),
        super(key: key);

  final Function equals = const DeepCollectionEquality().equals;

  @override
  Widget build(BuildContext context) {
    List<Object?>? built;
    return BlocBuilder<Cubit, BaseState<STATE, EVENT>>(
      buildWhen: (_, current) {
        if (current.state == null) return false;
        return !equals(built, properties(current.state as STATE)) &&
            (onStateUpdated == null || onStateUpdated!(current as STATE));
      },
      builder: (context, state) {
        built = properties(state.state as STATE);
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: onWidgetBuild(context, state.state as STATE),
        );
      },
    );
  }
}
