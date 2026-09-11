import 'package:nurnova_ai/core/extensions/date_extensions.dart';
import 'package:nurnova_ai/core/extensions/string_extensions.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DateSelectorList extends StatefulWidget {
  final DateTime? startDate;
  final DateTime selectedDate;
  final int count;
  final Function(DateTime) onDateSelected;
  final Function(DateTime)? onDateReselected;

  const DateSelectorList({
    Key? key,
    this.startDate,
    required this.selectedDate,
    required this.count,
    required this.onDateSelected,
    this.onDateReselected,
  }) : super(key: key);

  @override
  _DateSelectorListState createState() => _DateSelectorListState();
}

class _DateSelectorListState extends State<DateSelectorList> {
  late List<DateTime> dateList;
  late DateTime selectedDate;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;

  final double itemWidth = 46;
  final double spacing = 8;
  final double listPadding = 16;

  @override
  void initState() {
    super.initState();
    _generateDateList();
    selectedDate = widget.selectedDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _generateDateList() {
    dateList = List.generate(
      widget.count,
      (index) {
        return (widget.startDate ?? DateTime.now())
            .subtract(Duration(days: index));
      },
    );
  }

  void _scrollToSelectedDate() {
    if (_hasScrolled || dateList.isEmpty) return;

    try {
      int initialIndex =
          dateList.indexWhere((date) => date.isSameDay(selectedDate));
      if (initialIndex != -1) {
        _scrollToIndex(initialIndex);
        _hasScrolled = true;
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void _scrollToIndex(int index) {
    try {
      double viewportWidth = MediaQuery.of(context).size.width;
      double itemTotalWidth = itemWidth + spacing;
      double centerOffset =
          (index * itemTotalWidth) + (itemWidth / 2) - (viewportWidth / 2);

      _scrollController.animateTo(
        centerOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    String language = Localizations.localeOf(context).languageCode;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: dateList.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (buildContext, index) {
          var item = dateList[index];
          bool isSelected = item.isSameDay(selectedDate);

          return InkWell(
            onTap: () {
              HapticFeedback.heavyImpact();

              if (selectedDate == item) {
                if (widget.onDateReselected != null) {
                  widget.onDateReselected!(item);
                }
              } else {
                widget.onDateSelected(item);
              }

              setState(() => selectedDate = item);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 46,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF).withOpacity(isSelected ? 0.4 : 0.13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x21FFFFFF), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DateFormat('EE', language)
                      .format(item)
                      .substring(0, 2)
                      .capitalizePersonName()
                      .s(14)
                      .w(500)
                      .c(context.textPrimaryInverse),
                  DateFormat('dd')
                      .format(item)
                      .s(14)
                      .w(500)
                      .c(context.textPrimaryInverse),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 8),
      ),
    );
  }
}
