import 'package:auto_route/auto_route.dart';
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/domain/models/language/language.dart';
import 'package:baiqavisit/domain/models/theme/app_theme_mode.dart';
import 'package:baiqavisit/presentation/router/app_router.dart';
import 'package:baiqavisit/presentation/support/cubit/base_page.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/widgets/action/selection_list_item.dart';
import 'package:baiqavisit/presentation/widgets/app_bar/empty_app_bar.dart';
import 'package:baiqavisit/presentation/widgets/bottom_sheet/bottom_sheet_title.dart';
import 'package:baiqavisit/presentation/widgets/card/custom_card.dart';
import 'package:baiqavisit/presentation/widgets/divider/custom_divider.dart';
import 'package:baiqavisit/presentation/widgets/image/circle_cached_network_image_widget.dart';
import 'package:baiqavisit/presentation/widgets/profile/profile_item_widget.dart';
import 'package:easy_localization/easy_localization.dart';
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
        // context.router.replace(LoginRoute());
      case ProfileEventType.onTokenExpired:
        {}
      case ProfileEventType.onChangePinCode:
        // context.router.push(
        //   CheckPinCodeRoute(launchType: CheckPinCodeLaunchType.launchForEdit),
        // );
      case ProfileEventType.onChangePassword:
    }
  }

  @override
  Widget onWidgetBuild(BuildContext context, ProfileState state) {
    return Scaffold(
      appBar: EmptyAppBar(
        titleText: Strings.bottomNavigationSettings,
      ),
      backgroundColor: context.backgroundGreyColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // _buildProfileHeader(state),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Strings.profileMainBlock.s(14).w(400),
              ),
            ),
            SizedBox(height: 4),
            ..._buildMainBlock(context, state),
            SizedBox(height: 12),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Strings.profileSecurityBlock.s(14).w(400),
            //   ),
            // ),
            // SizedBox(height: 4),
            // ..._buildSecurityBlock(context, state),
            // SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Strings.profileControlBlock.s(14).w(400),
              ),
            ),
            SizedBox(height: 4),
            ..._buildControlBlock(context, state),
            SizedBox(height: 12),
            _buildAppVersionBlock(),
          ],
        ),
      ),
    );
  }

  /// Block builder methods

  Widget _buildProfileHeader(ProfileState state) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomCard(
            margin: const EdgeInsets.only(left: 16, right: 0.5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16, top: 12, right: 12, bottom: 12),
              child: CircleCachedNetworkImage(
                image: state.userPhoto,
                width: 80,
                height: 80,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CustomCard(
                    margin: const EdgeInsets.only(
                      left: 0.5,
                      right: 16,
                      bottom: 0.5,
                    ),
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        top: 12,
                        right: 12,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          state.userFullName.s(14).w(600).copyWith(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: CustomCard(
                    margin:
                        const EdgeInsets.only(left: 0.5, right: 16, top: 0.5),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              top: 8,
                              right: 12,
                              bottom: 12,
                            ),
                            child: state.tenantName.s(14).w(500).copyWith(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMainBlock(BuildContext context, ProfileState state) {
    return [
      CustomCard(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: ProfileItemWidget(
          name: Strings.profileChangeLanguage,
          icon: Assets.images.icProfileLanguage,
          topRadius: 12,
          onClicked: () => _showChangeLanguageBottomSheet(context, state),
        ),
      ),
      CustomCard(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 0.5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: ProfileItemWidget(
          name: Strings.profileDarkMode,
          icon: Assets.images.icProfileDarkMode,
          topRadius: 0,
          bottomRadius: 12,
          onClicked: () => _showThemeModeBottomSheet(context, state),
        ),
      ),
    ];
  }

  List<Widget> _buildSecurityBlock(BuildContext context, ProfileState state) {
    return [
      CustomCard(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: ProfileItemWidget(
          name: Strings.profileChangePinCode,
          icon: Assets.images.icProfileChangePinCode,
          topRadius: 12,
          onClicked: () => cubit(context).changePinCode(),
        ),
      ),
      CustomCard(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 0.5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: ProfileItemWidget(
          name: Strings.profileChangePassword,
          icon: Assets.images.icProfileChangePassword,
          topRadius: 0,
          bottomRadius: 12,
          onClicked: () => cubit(context).changePassword(),
        ),
      ),
    ];
  }

  List<Widget> _buildControlBlock(
    BuildContext context,
    ProfileState state,
  ) {
    return [
      CustomCard(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: ProfileItemWidget(
          name: Strings.profileLogout,
          icon: Assets.images.icProfileLogout,
          topRadius: 14,
          bottomRadius: 14,
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
      ),
    ];
  }

  Widget _buildAppVersionBlock() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center();
        } else if (snapshot.hasData) {
          return "${snapshot.data?.version} (${snapshot.data?.buildNumber})"
              .s(14)
              .w(500);
        } else {
          return Center();
        }
      },
    );
  }

  /// Bottom sheet showing methods

  void _showChangeLanguageBottomSheet(
    BuildContext context,
    ProfileState state,
  ) {
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return Material(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 12),
              BottomSheetTitle(title: Strings.languageTitle),
              SizedBox(height: 14),
              SelectionListItem(
                item: Language.uzbekLatin,
                title: Strings.languageUzbekLatin,
                isSelected: state.language == Language.uzbekLatin,
                onClicked: (item) {
                  _saveSelectedLanguage(context, item);
                  context.router.pop();
                },
              ),
              CustomDivider(height: 2, startIndent: 20, endIndent: 20),
              SelectionListItem(
                item: Language.englishUs,
                title: Strings.languageEnglishUs,
                isSelected: state.language == Language.englishUs,
                onClicked: (item) {
                  _saveSelectedLanguage(context, item);
                  context.router.pop();
                },
              ),
              CustomDivider(height: 2, startIndent: 20, endIndent: 20),
              SelectionListItem(
                item: Language.russianRu,
                title: Strings.languageRussianRu,
                isSelected: state.language == Language.russianRu,
                onClicked: (item) {
                  _saveSelectedLanguage(context, item);
                  context.router.pop();
                },
              ),
              SizedBox(height: 32)
            ],
          ),
        );
      },
    );
  }

  void _showThemeModeBottomSheet(
    BuildContext context,
    ProfileState state,
  ) {
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return Material(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 12),
              BottomSheetTitle(title: Strings.profileDarkMode),
              SizedBox(height: 14),
              SelectionListItem(
                item: AppThemeMode.darkMode,
                title: Strings.themeModeDarkMode,
                isSelected: state.appThemeMode == AppThemeMode.darkMode,
                onClicked: (item) {
                  cubit(context).setSelectedThemeMode(item);
                  context.router.pop();
                },
              ),
              CustomDivider(height: 2, startIndent: 20, endIndent: 20),
              SelectionListItem(
                item: AppThemeMode.lightMode,
                title: Strings.themeModeLightMode,
                isSelected: state.appThemeMode == AppThemeMode.lightMode,
                onClicked: (item) {
                  cubit(context).setSelectedThemeMode(item);
                  context.router.pop();
                },
              ),
              CustomDivider(height: 2, startIndent: 20, endIndent: 20),
              SelectionListItem(
                item: AppThemeMode.followSystem,
                title: Strings.themeModeSystem,
                isSelected: state.appThemeMode == AppThemeMode.followSystem,
                onClicked: (item) {
                  cubit(context).setSelectedThemeMode(item);
                  context.router.pop();
                },
              ),
              SizedBox(height: 32)
            ],
          ),
        );
      },
    );
  }

  void _saveSelectedLanguage(BuildContext context, Language language) {
    Locale locale = language.getLocale();
    EasyLocalization.of(context)?.setLocale(locale);
    cubit(context).setSelectedLanguage(language);
  }
}
