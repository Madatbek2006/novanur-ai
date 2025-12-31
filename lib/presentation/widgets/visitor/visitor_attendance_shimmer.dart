import 'package:baiqavisit/presentation/support/colors/static_colors.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/widgets/divider/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VisitorAttendanceShimmer extends StatelessWidget {
  const VisitorAttendanceShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Shimmer.fromColors(
                  baseColor: StaticColors.shimmerBaseColor,
                  highlightColor: StaticColors.shimmerHighLightColor,
                  child: Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: StaticColors.shimmerBaseColor,
                  highlightColor: StaticColors.shimmerHighLightColor,
                  child: Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )
              ],
            ),
          ),
          CustomDivider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: StaticColors.shimmerBaseColor,
                            highlightColor: StaticColors.shimmerHighLightColor,
                            child: Container(
                              width: 120,
                              height: 12,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    Shimmer.fromColors(
                      baseColor: StaticColors.shimmerBaseColor,
                      highlightColor: StaticColors.shimmerHighLightColor,
                      child: Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: StaticColors.shimmerBaseColor,
                            highlightColor: StaticColors.shimmerHighLightColor,
                            child: Container(
                              height: 12,
                              width: 135,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    Shimmer.fromColors(
                      baseColor: StaticColors.shimmerBaseColor,
                      highlightColor: StaticColors.shimmerHighLightColor,
                      child: Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(width: 6),
                    Shimmer.fromColors(
                      baseColor: StaticColors.shimmerBaseColor,
                      highlightColor: StaticColors.shimmerHighLightColor,
                      child: Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
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
