import 'package:nurnova_ai/core/extensions/date_extensions.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/domain/models/attendance/attendance.dart';
import 'package:nurnova_ai/presentation/support/colors/static_colors.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/widgets/image/rounded_cached_network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AttendanceWidget extends StatelessWidget {
  final Function(Attendance attendance) onClicked;
  final Attendance attendance;

  const AttendanceWidget({
    super.key,
    required this.onClicked,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: context.containerColorGrey,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.fromBorderSide(
          BorderSide(color: context.containerBorderColor, width: 1),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          onClicked(attendance);
          HapticFeedback.heavyImpact();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _builderFooter(context),
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
            child: Strings.commonAttendanceDate
                .s(14)
                .w(400)
                .c(context.textPrimary),
          ),
          SizedBox(width: 4),
          Container(
            constraints: BoxConstraints(minWidth: 45, minHeight: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: (attendance.isAbsent
                      ? StaticColors.attendanceAbsent
                      : attendance.isSpoofed
                          ? StaticColors.attendanceSpoofed
                          : StaticColors.attendanceAccepted)
                  .withOpacity(0.10),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: attendance.isAbsent
                ? Strings.commonAttAbsent
                    .s(12)
                    .w(500)
                    .c(StaticColors.attendanceAbsent)
                : attendance.createdAt
                    .changeDateFormat("", "HH:mm")
                    .s(12)
                    .w(500)
                    .c(
                      attendance.isSpoofed
                          ? StaticColors.attendanceSpoofed
                          : StaticColors.attendanceAccepted,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _builderFooter(BuildContext context) {
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
            image: attendance.identityPhoto,
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
                    Expanded(
                      child: attendance.fullName
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
                SizedBox(height: 8),
                Row(
                  children: [
                    Strings.commonIin.s(14).w(400).c(context.textPrimary),
                    SizedBox(width: 2),
                    Expanded(
                      child: attendance.iin
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
                Visibility(
                  visible: attendance.hasAttendance,
                  child: SizedBox(height: 8),
                ),
                Visibility(
                  visible: attendance.hasAttendance,
                  child: Row(
                    children: [
                      Strings.commonAttType.s(14).w(400).c(context.textPrimary),
                      SizedBox(width: 2),
                      Expanded(
                        child: (attendance.isAutoAtt
                                ? Strings.commonAttTypeAuto
                                : Strings.commonAttTypeManual)
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
