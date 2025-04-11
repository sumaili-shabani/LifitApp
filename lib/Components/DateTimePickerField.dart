import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerField extends StatefulWidget {
  final bool selectDate;
  final bool selectTime;
  final String label;
  final void Function(String)? onChanged;

  const DateTimePickerField({
    super.key,
    this.selectDate = true,
    this.selectTime = true,
    this.onChanged,
    required this.label,
  });

  @override
  State<DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<DateTimePickerField> {
  TextEditingController controller = TextEditingController();
  DateTime? selectedDateTime;

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate =
        widget.selectDate
            ? await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            )
            : now;

    if (pickedDate != null) {
      TimeOfDay? pickedTime =
          widget.selectTime
              ? await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(now),
              )
              : TimeOfDay(hour: 0, minute: 0);

      if (pickedTime != null) {
        DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        String formatted = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(fullDateTime);

        setState(() {
          selectedDateTime = fullDateTime;
          controller.text = formatted;
        });

        if (widget.onChanged != null) {
          widget.onChanged!(formatted);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDateTime(context),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
    );
  }
}
