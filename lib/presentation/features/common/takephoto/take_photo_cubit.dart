import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_cubit.dart';

part 'take_photo_cubit.freezed.dart';

part 'take_photo_state.dart';

/// Holds the captured photo only. The camera is owned by the page through
/// `AppCameraController` — see `app_camera_controller.dart`.
@injectable
class TakePhotoCubit extends BaseCubit<TakePhotoState, TakePhotoEvent> {
  TakePhotoCubit() : super(const TakePhotoState());

  void setTakenPhoto(XFile photo, String photoBase64) {
    updateState((state) => state.copyWith(
          takenPhotoFile: photo,
          takenPhotoInBase64: photoBase64,
        ));
  }

  void showPicture() {
    emitEvent(const TakePhotoEvent(TakePhotoEventType.onShowTakenPhoto));
  }
}
