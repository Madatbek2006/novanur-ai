import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nurnova_ai/core/handler/future_handler.dart';
import 'package:nurnova_ai/data/repositories/photo_analysis_repository.dart';
import 'package:nurnova_ai/domain/models/dashboard/dashboard_button_data.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_cubit.dart';

part 'dashboard_cubit.freezed.dart';

part 'dashboard_state.dart';

/// Dashboard screen state only. The camera is owned by the page through
/// `AppCameraController` — see `app_camera_controller.dart`.
@injectable
class DashboardCubit extends BaseCubit<DashboardState, DashboardEvent> {
  DashboardCubit(this._photoAnalysisRepository) : super(const DashboardState());

  final PhotoAnalysisRepository _photoAnalysisRepository;
  final FlutterTts _tts = FlutterTts();

  bool _isLookingUpBarcode = false;

  @override
  Future<void> close() async {
    await _tts.stop();
    return super.close();
  }

  void setDashboardButtonType(DashboardButtonType type) {
    updateState((state) => state.copyWith(type: type));
  }

  void setTakenPhoto(XFile photo) {
    updateState((state) => state.copyWith(takenPhotoFile: photo));
  }

  /// Resolves a scanned barcode to a product name and speaks it. New scans are
  /// ignored while a lookup is still in flight.
  void getProductData(String? barcode) {
    if (_isLookingUpBarcode || barcode == null || barcode.isEmpty) return;
    _isLookingUpBarcode = true;

    _photoAnalysisRepository
        .getProductData(barcode)
        .initFuture()
        .onSuccess((data) => _tts.speak(data))
        .onError((error) => logger.w('Barcode lookup failed: $error'))
        .onFinished(() => _isLookingUpBarcode = false)
        .executeFuture();
  }
}
