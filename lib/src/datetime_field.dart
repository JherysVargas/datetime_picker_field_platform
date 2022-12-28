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
    required this.maximumDate,
    required this.minimumDate,
    this.initialDate,
    this.decoration = const InputDecoration(),
    this.mode = DateMode.date,
    this.title = "Select",
    this.textCancel = "Cancel",
    this.textConfirm = "Confirm",
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

  /// Optional, the date type to use. Default is [DateMode.date].
  final DateMode mode;

  /// Optional, this is used to indicate to the user what they are selecting a date for. Default is [Select].
  final String? title;

  /// Optional, format applied when selecting a [DateMode.date]. Default is [dd/MM/yyyy].
  final String? dateFormatter;

  /// Optional, format applied when selecting a [DateMode.time]. Default is [hh:mm aa].
  final String? timeFormatter;

  /// Optional, text to display on the cancel button. Default is [Cancel].
  final String? textCancel;

  /// Optional, text to display on the confirm button. Default is [Confirm].
  final String? textConfirm;

  /// Optional, init date. Default is current date.
  final DateTime? initialDate;

  /// Required, maximum date that can be selected.
  final DateTime maximumDate;

  /// Required, minimum date that can be selected.
  final DateTime minimumDate;

  /// Optional, this to be applied to the style of the [TextFormField].
  final TextStyle? inputStyle;

  /// Optional, this to be applied to the style of the [title].
  final TextStyle? titleStyle;

  /// Optional, this to be applied to the style of the [textCancel].
  final TextStyle? textCancelStyle;

  /// Optional, this to be applied to the style of the [textConfirm].
  final TextStyle? textConfirmStyle;

  /// Optional, this to be applied to the decoration of the [TextFormField].
  final InputDecoration? decoration;

  /// Optional, called when the cancel button is pressed.
  final VoidCallback? onCancel;

  /// Optional, called when the confirm button is pressed
  final Function(DateTime)? onConfirm;

  /// Optional, this is the controller of the [TextFormField].
  final TextEditingController? controller;

  /// Optional, this will be applied to the validator of the [TextFormField].
  final FormFieldValidator<String>? validator;

  @override
  State<DateTimeFieldPlatform> createState() => _DateTimeFieldPlatformState();
}

class _DateTimeFieldPlatformState extends State<DateTimeFieldPlatform> {
  Jiffy selectedDate = Jiffy();
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();

    if (widget.initialDate != null) {
      selectedDate = Jiffy(widget.initialDate);
      _controller.text = selectedDate.format(_getFormattedDate());
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
    switch (widget.mode) {
      case DateMode.time:
        {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(selectedDate.dateTime),
            cancelText: widget.textCancel,
            confirmText: widget.textConfirm,
            helpText: widget.title,
          );
          if (picked != null &&
              picked != TimeOfDay.fromDateTime(selectedDate.dateTime)) {
            final parseSelectedDate = _parseSelectedDate(picked);
            _controller.text =
                Jiffy(parseSelectedDate).format(_getFormattedDate());
            selectedDate = Jiffy(parseSelectedDate);
            widget.onConfirm?.call(parseSelectedDate);
          }
        }
        break;
      default:
        {
          final DateTime? picked = await showDatePicker(
            context: context,
            cancelText: widget.textCancel,
            confirmText: widget.textConfirm,
            helpText: widget.title,
            initialDate: selectedDate.dateTime,
            firstDate: widget.minimumDate,
            lastDate: widget.maximumDate,
          );
          if (picked != null && picked != selectedDate.dateTime) {
            selectedDate = Jiffy(picked);
            _controller.text = selectedDate.format(_getFormattedDate());
            widget.onConfirm?.call(selectedDate.dateTime);
          }
        }
    }
  }

  void showPickerDateTimeIOS() {
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (context) => _renderDatetimeIOS(),
    );
  }

  Widget _renderDatetimeIOS() {
    DateTime changeDate = selectedDate.dateTime;

    return DateTimePickerIOS(
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
        selectedDate = Jiffy(changeDate);
        widget.onConfirm?.call(changeDate);
        Navigator.of(context).pop();
      },
      onDateTimeChanged: (value) {
        changeDate = value;
      },
      initialDateTime: selectedDate.dateTime,
      minimumDate: widget.minimumDate,
      maximumDate: widget.maximumDate,
      titleStyle: widget.titleStyle,
      textCancelStyle: widget.textCancelStyle,
      textConfirmStyle: widget.textConfirmStyle,
    );
  }

  DateTime _parseSelectedDate(TimeOfDay selectedTime) {
    return DateTime.utc(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }
}
