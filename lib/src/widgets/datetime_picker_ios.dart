import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../datetime_field.dart';

class DateTimePickerIOS extends StatelessWidget {
  const DateTimePickerIOS({
    Key? key,
    required this.mode,
    required this.title,
    required this.textCancel,
    required this.textConfirm,
    required this.initialDateTime,
    required this.onDateTimeChanged,
    this.onCancel,
    this.onConfirm,
    this.minimumDate,
    this.maximumDate,
    this.titleStyle,
    this.textCancelStyle,
    this.textConfirmStyle,
  }) : super(key: key);

  final DateMode mode;
  final String title;
  final String textCancel;
  final String textConfirm;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final DateTime initialDateTime;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final TextStyle? titleStyle;
  final TextStyle? textCancelStyle;
  final TextStyle? textConfirmStyle;
  final void Function(DateTime) onDateTimeChanged;

  static const TextStyle _kDefaultTextButtonStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle _kDefaultTitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onCancel,
                child: Text(
                  textCancel,
                  style: _kDefaultTextButtonStyle
                      .copyWith(color: Theme.of(context).primaryColor)
                      .merge(textCancelStyle),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: _kDefaultTitleStyle.merge(titleStyle),
                ),
              ),
              InkWell(
                onTap: onConfirm,
                child: Text(
                  textConfirm,
                  style: _kDefaultTextButtonStyle
                      .copyWith(color: Theme.of(context).primaryColor)
                      .merge(textConfirmStyle),
                ),
              ),
            ],
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: mode == DateMode.time
                  ? CupertinoDatePickerMode.time
                  : CupertinoDatePickerMode.date,
              onDateTimeChanged: onDateTimeChanged,
              initialDateTime: initialDateTime,
              minimumDate: minimumDate,
              maximumDate: maximumDate,
            ),
          ),
        ],
      ),
    );
  }
}
