import 'package:auto_route/auto_route.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/data/datasource/preference/speech_rate_preferences.dart';
import 'package:nurnova_ai/domain/models/language/language.dart';
import 'package:nurnova_ai/domain/models/theme/app_theme_mode.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/web_ui.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_page.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';
import 'package:nurnova_ai/presentation/widgets/action/selection_list_item.dart';
import 'package:nurnova_ai/presentation/widgets/app_bar/empty_app_bar.dart';
import 'package:nurnova_ai/presentation/widgets/bottom_sheet/bottom_sheet_title.dart';
import 'package:nurnova_ai/presentation/widgets/card/custom_card.dart';
import 'package:nurnova_ai/presentation/widgets/divider/custom_divider.dart';
import 'package:nurnova_ai/presentation/widgets/profile/profile_item_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'profile_cubit.dart';

@RoutePage()
class ProfilePage extends BasePage<ProfileCubit, ProfileState, ProfileEvent> {
  ProfilePage({super.key});

  @override
  void onEventEmitted(BuildContext context, ProfileEvent event) {
    switch (event.type) {
      case ProfileEventType.onLogOut:
      case ProfileEventType.onTokenExpired:
      case ProfileEventType.onChangePinCode:
      case ProfileEventType.onChangePassword:
        break;
    }
  }

  @override
  Widget onWidgetBuild(BuildContext context, ProfileState state) {
    final bool dark = context.isDarkMode;
    return Scaffold(
      appBar: EmptyAppBar(titleText: Strings.bottomNavigationSettings),
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [
                    Color(0xFF0D1117),
                    Color(0xFF161B27),
                    Color(0xFF0A0E1A),
                  ]
                : const [
                    Color(0xFFEEF2FF),
                    Color(0xFFE1EAFF),
                    Color(0xFFF0F4FF),
                  ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          // Browser windows are wide; keep the settings list readable.
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: kIsWeb ? 720 : double.infinity,
              ),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 72),
                  _sectionLabel(context, Strings.profileMainBlock),
                  _buildMainBlock(context, state),
                  const SizedBox(height: 22),
                  _sectionLabel(context, Strings.profileControlBlock),
                  _buildControlBlock(context),
                  const SizedBox(height: 24),
                  _buildAppVersionBlock(),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom +
                        (_isWideWeb(context) ? 24 : 110),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: title.toUpperCase().s(11).w(700).c(
              context.primaryLight.withOpacity(0.9),
            ),
      ),
    );
  }

  Widget _buildMainBlock(BuildContext context, ProfileState state) {
    return CustomCard(
      isGlass: true,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      borderRadius: AppGlass.cardAll,
      child: Column(
        children: [
          ProfileItemWidget(
            name: Strings.profileChangeLanguage,
            icon: Assets.images.icProfileLanguage,
            topRadius: AppGlass.radiusCard,
            onClicked: () => _showChangeLanguageBottomSheet(context, state),
          ),
          CustomDivider(height: 1, startIndent: 68, endIndent: 16),
          ProfileItemWidget(
            name: Strings.profileDarkMode,
            icon: Assets.images.icProfileDarkMode,
            onClicked: () => _showThemeModeBottomSheet(context, state),
          ),
          CustomDivider(height: 1, startIndent: 68, endIndent: 16),
          _buildSpeechRate(context, state),
        ],
      ),
    );
  }

  /// Скорость чтения ответов вслух. Слайдер, а не список вариантов: комфортный
  /// темп у каждого свой, а привыкшие к скринридерам слушают заметно быстрее
  /// обычного.
  Widget _buildSpeechRate(BuildContext context, ProfileState state) {
    // В шкале flutter_tts обычная скорость — 0.5, поэтому на экране
    // показываем привычный множитель.
    final multiplier = state.speechRate / SpeechRatePreferences.normal;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.profileSpeechRate,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Text(
                "${multiplier.toStringAsFixed(1)}\u00d7",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Slider(
            value: state.speechRate,
            min: SpeechRatePreferences.min,
            max: SpeechRatePreferences.max,
            // Шаг в 0.05 даёт 0.5x, 0.6x, ... 2.0x — попасть пальцем реально.
            divisions:
                ((SpeechRatePreferences.max - SpeechRatePreferences.min) / 0.05)
                    .round(),
            label: "${multiplier.toStringAsFixed(1)}\u00d7",
            onChanged: (value) => cubit(context).setSpeechRate(value),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBlock(BuildContext context) {
    return CustomCard(
      isGlass: true,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      borderRadius: AppGlass.cardAll,
      child: ProfileItemWidget(
        name: Strings.profileLogout,
        icon: Assets.images.icProfileLogout,
        isDestructive: true,
        topRadius: AppGlass.radiusCard,
        bottomRadius: AppGlass.radiusCard,
        onClicked: () {
          showYesNoBottomSheet(
            context,
            title: Strings.profileLogoutTitle,
            message: Strings.profileLogoutDescription,
            noTitle: Strings.commonNo,
            onNoClicked: () {},
            yesTitle: Strings.commonYes,
            onYesClicked: () => cubit(context).logOut(),
          );
        },
      ),
    );
  }

  Widget _buildAppVersionBlock() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) return const SizedBox(height: 20);

        return "${info.version} (${info.buildNumber})"
            .s(13)
            .w(500)
            .c(context.textPrimary.withOpacity(0.45));
      },
    );
  }

  /// Bottom sheet showing methods

  void _showChangeLanguageBottomSheet(
    BuildContext context,
    ProfileState state,
  ) {
    // The language in use, which may come from the device rather than a
    // saved choice.
    final current = context.locale.languageCode;
    _showGlassSheet(
      context,
      title: Strings.languageTitle,
      children: [
        SelectionListItem(
          item: Language.uzbekLatin,
          title: Strings.languageUzbekLatin,
          isSelected: current == Language.uzbekLatin.getRestCode(),
          onClicked: (item) {
            _saveSelectedLanguage(context, item);
            context.router.pop();
          },
        ),
        CustomDivider(height: 1, startIndent: 20, endIndent: 20),
        SelectionListItem(
          item: Language.englishUs,
          title: Strings.languageEnglishUs,
          isSelected: current == Language.englishUs.getRestCode(),
          onClicked: (item) {
            _saveSelectedLanguage(context, item);
            context.router.pop();
          },
        ),
        CustomDivider(height: 1, startIndent: 20, endIndent: 20),
        SelectionListItem(
          item: Language.russianRu,
          title: Strings.languageRussianRu,
          isSelected: current == Language.russianRu.getRestCode(),
          onClicked: (item) {
            _saveSelectedLanguage(context, item);
            context.router.pop();
          },
        ),
      ],
    );
  }

  void _showThemeModeBottomSheet(
    BuildContext context,
    ProfileState state,
  ) {
    _showGlassSheet(
      context,
      title: Strings.profileDarkMode,
      children: [
        SelectionListItem(
          item: AppThemeMode.lightMode,
          title: Strings.themeModeLightMode,
          isSelected: state.appThemeMode == AppThemeMode.lightMode,
          onClicked: (item) {
            cubit(context).setSelectedThemeMode(item);
            context.router.pop();
          },
        ),
        CustomDivider(height: 1, startIndent: 20, endIndent: 20),
        SelectionListItem(
          item: AppThemeMode.darkMode,
          title: Strings.themeModeDarkMode,
          isSelected: state.appThemeMode == AppThemeMode.darkMode,
          onClicked: (item) {
            cubit(context).setSelectedThemeMode(item);
            context.router.pop();
          },
        ),
        CustomDivider(height: 1, startIndent: 20, endIndent: 20),
        SelectionListItem(
          item: AppThemeMode.followSystem,
          title: Strings.themeModeSystem,
          isSelected: state.appThemeMode == AppThemeMode.followSystem,
          onClicked: (item) {
            cubit(context).setSelectedThemeMode(item);
            context.router.pop();
          },
        ),
      ],
    );
  }

  /// The bottom navigation bar is replaced by a side rail in wide browser
  /// windows, where a centered dialog also fits better than a bottom sheet.
  bool _isWideWeb(BuildContext context) =>
      kIsWeb && WebBreakpoints.isWide(context);

  void _showGlassSheet(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    if (_isWideWeb(context)) {
      showDialog<void>(
        context: context,
        // The router's navigator: the app theme applies and
        // context.router.pop() closes it.
        useRootNavigator: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GlassSurface(
              blur: AppGlass.blurPanel,
              borderRadius: AppGlass.panelAll,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BottomSheetTitle(title: title, showHandle: false),
                  const SizedBox(height: 12),
                  ...children,
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }
    showCupertinoModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassSheet(
        showGrabber: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BottomSheetTitle(title: title),
            const SizedBox(height: 12),
            ...children,
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _saveSelectedLanguage(BuildContext context, Language language) {
    Locale locale = language.getLocale();
    EasyLocalization.of(context)?.setLocale(locale);
    cubit(context).setSelectedLanguage(language);
  }
}
