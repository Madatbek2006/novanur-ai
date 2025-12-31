import 'package:equatable/equatable.dart';

class BaseState<STATE, EVENT> implements Equatable {
  final STATE? state;
  final EVENT? event;

  BaseState({this.state, this.event});

  @override
  List<Object?> get props => [state, event];

  @override
  bool? get stringify => false;
}
