import 'package:flutter/material.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';

class DropdownFormField extends StatelessWidget {
  const DropdownFormField({
    super.key,
    this.height = 45,
    this.value = "",
    required this.hint,
    required this.onTap,
    this.autoValidateMode,
    this.validator,
  });

  final double height;
  final String value;
  final String hint;
  final Function() onTap;
  final AutovalidateMode? autoValidateMode;
  final String? Function(String? text)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: (v) {
        return validator != null ? validator!(value) : null;
      },
      builder: (state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: context.inputBackgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 1,
                  color: state.hasError
                      ? Colors.red.shade200
                      : context.inputStrokeInactiveColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () => onTap(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: (value.isNotEmpty
                                ? (value).w(400).s(14).c(context.textPrimary)
                                : (hint).w(400).s(14).c(context.textSecondary))
                            .copyWith(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Assets.images.component.dropdown.svg()
                    ],
                  ),
                ),
              ),
            ),
            if (state.hasError) SizedBox(height: 8),
            if (state.hasError)
              Row(
                children: [
                  SizedBox(width: 16),
                  (state.errorText!).s(12).c(Colors.red).copyWith(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                ],
              ),
          ],
        );
      },
    );
  }
}
