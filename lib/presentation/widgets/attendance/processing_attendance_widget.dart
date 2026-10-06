import 'package:nurnova_ai/core/extensions/date_extensions.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/domain/models/attendance/processing_attendance.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/widgets/image/rounded_cached_network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProcessingAttendanceWidget extends StatelessWidget {
  final Function(ProcessingAttendance attendance) onClicked;
  final ProcessingAttendance attendance;

  const ProcessingAttendanceWidget({
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
            child: Strings.commonProcessingAttSubmissionDate
                .s(14)
                .w(400)
                .c(context.textPrimary),
          ),
          SizedBox(width: 4),
          Container(
            constraints: BoxConstraints(minWidth: 45, minHeight: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: Color(0xFFFF8A00).withOpacity(0.10),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: attendance.createdAt
                .changeDateFormat("", "dd.MM.yyyy HH:mm")
                .s(12)
                .w(500)
                .c(Color(0xFFFF8A00)),
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
            image: attendance.attendancePhoto,
            width: 64,
            height: 72,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Strings.commonProcessingAttSubmissionDevice
                    .s(14)
                    .w(400)
                    .c(context.textPrimary),
                SizedBox(height: 4),
                attendance.deviceName
                    .s(14)
                    .w(600)
                    .c(context.textPrimary)
                    .copyWith(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
