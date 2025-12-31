import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:flutter/material.dart';

class BottomSheetTitle extends StatelessWidget {
  const BottomSheetTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            SizedBox(width: 16),
            Expanded(
              child: title.s(18).w(600).copyWith(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
            SizedBox(width: 16),
          ],
        ),
      ],
    );
  }
}
