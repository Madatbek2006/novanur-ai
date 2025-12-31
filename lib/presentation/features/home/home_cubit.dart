import 'package:baiqavisit/presentation/support/cubit/base_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

@Injectable()
class HomeCubit extends BaseCubit<HomeState, HomeEvent> {
  HomeCubit() : super(HomeState()) {
    _subscribeStreams();
  }

  void _subscribeStreams() {}
}
