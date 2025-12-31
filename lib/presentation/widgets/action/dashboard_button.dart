
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:baiqavisit/domain/models/dashboard/dashboard_button_data.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/widgets/card/custom_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardButton extends StatelessWidget{
 final DashboardButtonType data;
 final bool isClicked;

  final Function(DashboardButtonType)? onPressed;

  const DashboardButton({super.key, required this.data, this.onPressed, required this.isClicked});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: (){onPressed?.call(data);},
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomCard(
              borderRadius: BorderRadius.circular(12),
              color: context.appBarColor,
              child: CustomCard(
                color: isClicked?context.primaryLight.withValues(alpha: 0.5):context.appBarColor,
                  borderRadius: BorderRadius.circular(12),
                  padding: EdgeInsets.all(6),
                  border: Border.all(
                      width:3,
                      color: context.iconPrimary
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: data.icon(context),
                  )
              ),
            ),
            SizedBox(height: 4),
            data.title.s(10).w(600).copyWith(
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,

            )
          ],
        ),
      ),
    );
  }

}