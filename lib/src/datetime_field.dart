import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';

import 'constants/constants.dart';
import 'widgets/datetime_picker_ios.dart';

enum DateMode {
  time,
  date,
}

class DateTimeFieldPlatform extends StatefulWidget {
  const DateTimeFieldPlatform({
    Key? key,
    this.initialDate,
    this.decoration = const InputDecoration(),
    this.mode = DateMode.date,
    this.title = "Seleccionar",
    this.textCancel = "Cancelar",
    this.textConfirm = "Aceptar",
    this.onCancel,
    this.validator,
    this.onConfirm,
    this.inputStyle,
    this.titleStyle,
    this.controller,
    this.textCancelStyle,
    this.textConfirmStyle,
    this.dateFormatter = dateFormat,
    this.timeFormatter = timeFormat,
  }) : super(key: key);

  final DateMode mode;
  final String? title;
  final String? dateFormatter;
  final String? timeFormatter;
  final String? textCancel;
  final String? textConfirm;
  final DateTime? initialDate;
  final VoidCallback? onCancel;
  final TextStyle? inputStyle;
  final TextStyle? titleStyle;
  final TextStyle? textCancelStyle;
  final InputDecoration? decoration;
  final TextStyle? textConfirmStyle;
  final Function(DateTime)? onConfirm;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  @override
  State<DateTimeFieldPlatform> createState() => _DateTimeFieldPlatformState();
}

class _DateTimeFieldPlatformState extends State<DateTimeFieldPlatform> {
  Jiffy? dateTime;
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();

    if (widget.initialDate != null) {
      dateTime = Jiffy(widget.initialDate);
      _controller.text = dateTime!.format(_getFormattedDate());
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tootlePicker,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _controller,
          style: widget.inputStyle,
          validator: widget.validator,
          decoration: widget.decoration,
        ),
      ),
    );
  }

  String _getFormattedDate() {
    if (widget.mode == DateMode.date) {
      return widget.dateFormatter!;
    }
    return widget.timeFormatter!;
  }

  void tootlePicker() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        showPickerDateTimeIOS();
        break;
      default:
        showPickerDateTimeAndroid();
    }
  }

  Future<void> showPickerDateTimeAndroid() async {
    final selectedDate = dateTime ?? Jiffy();

    switch (widget.mode) {
      case DateMode.time:
        {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(selectedDate.dateTime),
            confirmText: widget.textCancel,
            cancelText: widget.textConfirm,
            helpText: widget.title,
          );
          if (picked != null &&
              picked != TimeOfDay.fromDateTime(selectedDate.dateTime)) {
            final parseSelectedDate = _parseSelectedDate(picked, selectedDate);
            _controller.text =
                Jiffy(parseSelectedDate).format(_getFormattedDate());
            dateTime = Jiffy(parseSelectedDate);
            widget.onConfirm?.call(parseSelectedDate);
          }
        }
        break;
      default:
        {
          final DateTime? picked = await showDatePicker(
            context: context,
            confirmText: widget.textCancel,
            cancelText: widget.textConfirm,
            helpText: widget.title,
            initialDate: selectedDate.dateTime,
            firstDate: _parseSelectedDate(selectedDate),
            lastDate: selectedDate.add(months: maximumDateMonths).dateTime,
          );
          if (picked != null && picked != selectedDate.dateTime) {
            dateTime = Jiffy(picked);
            _controller.text = dateTime!.format(_getFormattedDate());
            widget.onConfirm?.call(dateTime!.dateTime);
          }
        }
    }
  }

  void showPickerDateTimeIOS() {
    final selectedDate = dateTime ?? Jiffy();
    DateTime changeDate = selectedDate.dateTime;
    showModalBottomSheet(
      context: context,
      // enableDrag: false,
      // isDismissible: false,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (context) => _renderDatetimeIOS(
        selectedDate: selectedDate,
        changeDate: changeDate,
      ),
    );
  }

  Widget _renderDatetimeIOS({
    required Jiffy selectedDate,
    required DateTime changeDate,
  }) =>
      DateTimePickerIOS(
        mode: widget.mode,
        title: widget.title!,
        textCancel: widget.textCancel!,
        textConfirm: widget.textConfirm!,
        onCancel: () {
          widget.onCancel?.call();
          Navigator.of(context).pop();
        },
        onConfirm: () {
          _controller.text = Jiffy(changeDate).format(_getFormattedDate());
          dateTime = Jiffy(changeDate);
          widget.onConfirm?.call(changeDate);
          Navigator.of(context).pop();
        },
        onDateTimeChanged: (value) {
          changeDate = value;
        },
        initialDateTime: selectedDate.dateTime,
        minimumYear: selectedDate.year,
        minimumDate: _parseSelectedDate(selectedDate),
        maximumDate: Jiffy().add(months: maximumDateMonths).dateTime,
        titleStyle: widget.titleStyle,
        textCancelStyle: widget.textCancelStyle,
        textConfirmStyle: widget.textConfirmStyle,
      );

  DateTime _parseSelectedDate(dynamic selectedDate, [dynamic currentDate]) {
    final DateTime date = currentDate ?? DateTime.now();
    return DateTime(
      date.year,
      date.month,
      date.day,
      selectedDate.hour,
      selectedDate.minute,
    );
  }
}
