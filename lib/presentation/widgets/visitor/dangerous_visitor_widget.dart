import 'package:baiqavisit/core/extensions/date_extensions.dart';
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/domain/models/visitor/dangerous_visitor.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/widgets/card/custom_container.dart';
import 'package:baiqavisit/presentation/widgets/image/rounded_cached_network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DangerousVisitorWidget extends StatelessWidget {
  final DangerousVisitor visitor;
  final Function(DangerousVisitor visitor) onClicked;

  const DangerousVisitorWidget({
    super.key,
    required this.visitor,
    required this.onClicked,
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
          onClicked(visitor);
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Expanded(child: "№ ${visitor.id}".s(14).w(400).c(context.textPrimary)),
          SizedBox(width: 4),
          visitor.recordedAt
              .toDateString(format: "hh:mm")
              .s(14)
              .w(400)
              .c(context.textPrimary),
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
            image: visitor.recognitionFaceImage,
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
                      child: visitor.fullName
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
                      child: visitor.iin
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
