import 'package:baiqavisit/core/enum/enums.dart';
import 'package:baiqavisit/presentation/widgets/state/default_empty_widget.dart';
import 'package:baiqavisit/presentation/widgets/state/default_error_widget.dart';
import 'package:baiqavisit/presentation/widgets/state/default_loading_widget.dart';
import 'package:flutter/material.dart';

class LoaderStateWidget extends StatelessWidget {
  const LoaderStateWidget({
    super.key,
    required this.loadingState,
    this.initialBody,
    this.loadingBody,
    required this.successBody,
    this.emptyBody,
    this.errorBody,
    this.onErrorRetryAction,
    this.onEmptyReloadAction,
    this.isFullScreen = false,
  });

  final bool isFullScreen;
  final LoadingState loadingState;
  final Widget successBody;
  final Widget? initialBody;
  final Widget? loadingBody;
  final Widget? emptyBody;
  final Widget? errorBody;
  final VoidCallback? onErrorRetryAction;
  final VoidCallback? onEmptyReloadAction;

  @override
  Widget build(BuildContext context) {
    return switch (loadingState) {
      LoadingState.initial => initialBody ?? _buildDefaultInitialBody(),
      LoadingState.loading => loadingBody ?? _buildDefaultLoadingBody(),
      LoadingState.success => successBody,
      LoadingState.empty => emptyBody ?? _buildDefaultEmptyBody(),
      LoadingState.error => errorBody ?? _buildDefaultErrorBody(),
    };
  }

  Widget _buildDefaultInitialBody() {
    return Center();
  }

  Widget _buildDefaultLoadingBody() {
    return DefaultLoadingWidget(isFullScreen: isFullScreen);
  }

  Widget _buildDefaultEmptyBody() {
    return DefaultEmptyWidget(
      isFullScreen: isFullScreen,
      onReloadClicked: onEmptyReloadAction,
    );
  }

  Widget _buildDefaultErrorBody() {
    return DefaultErrorWidget(
      isFullScreen: isFullScreen,
      onRetryClicked: onErrorRetryAction,
    );
  }
}
