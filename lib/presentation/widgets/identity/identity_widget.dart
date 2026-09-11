import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/domain/models/identity/identity.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/widgets/card/custom_container.dart';
import 'package:nurnova_ai/presentation/widgets/image/rounded_cached_network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IdentityWidget extends StatelessWidget {
  final Function(Identity identity) onClicked;
  final Identity identity;

  const IdentityWidget({
    super.key,
    required this.onClicked,
    required this.identity,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      margin: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
      border: Border.fromBorderSide(
        BorderSide(color: context.containerBorderColor, width: 1),
      ),
      borderRadius: BorderRadius.all(Radius.circular(10)),
      backgroundColor: context.containerColorGrey,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          onClicked(identity);
          HapticFeedback.heavyImpact();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.containerColorGrey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border(
          bottom: BorderSide(color: context.containerBorderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: "№ ${identity.id}".s(14).w(400).c(context.textPrimary),
          ),
          SizedBox(width: 4),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: Color(0xFF579ECD),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 6),
            child: InkWell(
              onTap: () {
                onClicked(identity);
                HapticFeedback.heavyImpact();
              },
              child: Row(
                children: [
                  SizedBox(width: 12),
                  Strings.commonEdit.s(12).w(400).c(context.textPrimaryInverse),
                  SizedBox(width: 4),
                  Assets.images.icEdit.svg(),
                  SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.containerColorWhite,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundedCachedNetworkImage(
            image: identity.identityPhoto,
            width: 64,
            height: 72,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Strings.commonFullName.s(14).w(400).c(context.textPrimary),
                    SizedBox(width: 2),
                    Expanded(
                      child: identity.fullName
                          .s(14)
                          .w(600)
                          .c(context.textPrimary)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Strings.commonIin.s(14).w(400).c(context.textPrimary),
                    SizedBox(width: 2),
                    Expanded(
                      child: identity.iin
                          .s(14)
                          .w(600)
                          .c(context.textPrimary)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    (identity.isEmployee
                            ? Strings.commonEmployeeRole
                            : Strings.commonGroup)
                        .s(14)
                        .w(400)
                        .c(context.textPrimary),
                    SizedBox(width: 2),
                    Expanded(
                      child: (identity.isEmployee
                              ? identity.role
                              : identity.groupName)
                          .s(14)
                          .w(600)
                          .c(context.textPrimary)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
