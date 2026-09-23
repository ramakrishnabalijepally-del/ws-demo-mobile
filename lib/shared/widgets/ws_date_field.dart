import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import 'ws_buttons.dart';
import 'ws_forms.dart';

/// A date field that opens a wheel picker in a bottom sheet instead of the
/// keyboard.
///
/// The controller keeps holding `YYYY-MM-DD`, so callers validate and save it
/// exactly as they did when the date was typed.
class WsDateField extends StatelessWidget {
  const WsDateField({
    required this.label,
    required this.controller,
    this.helper,
    this.error,
    this.required = false,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? helper;
  final String? error;
  final bool required;
  final VoidCallback? onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showWsDatePickerSheet(
      context,
      title: label,
      initial: DateTime.tryParse(controller.text.trim()),
    );
    if (picked == null) return;
    controller.text = _iso(picked);
    onChanged?.call();
  }

  static String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return WsField(
      label: label,
      required: required,
      controller: controller,
      hint: 'Choose a date',
      helper: helper,
      error: error,
      readOnly: true,
      leadingIcon: Icons.calendar_today_outlined,
      trailingIcon: Icons.expand_more_rounded,
      onTrailingTap: () => _pick(context),
      onTap: () => _pick(context),
    );
  }
}

/// Opens the date sheet and resolves to the chosen date, or null if the
/// reader dismisses it.
Future<DateTime?> showWsDatePickerSheet(
  BuildContext context, {
  required String title,
  DateTime? initial,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = initial == null || initial.isAfter(today)
      ? DateTime(today.year - 30, today.month, today.day)
      : initial;

  return showModalBottomSheet<DateTime>(
    context: context,
    sheetAnimationStyle: WsMotion.reduced(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: WsMotion.slow,
            curve: WsMotion.emphasized,
            reverseDuration: WsMotion.medium,
          ),
    builder: (_) => _DateSheet(
      title: title,
      initial: start,
      minimum: DateTime(1900),
      maximum: today,
    ),
  );
}

class _DateSheet extends StatefulWidget {
  const _DateSheet({
    required this.title,
    required this.initial,
    required this.minimum,
    required this.maximum,
  });

  final String title;
  final DateTime initial;
  final DateTime minimum;
  final DateTime maximum;

  @override
  State<_DateSheet> createState() => _DateSheetState();
}

class _DateSheetState extends State<_DateSheet> {
  late DateTime _value = widget.initial;

  /// Tall enough for five rows at 200% text; it scrolls rather than clips.
  static const double _wheelHeight = 216;

  @override
  Widget build(BuildContext context) {
    final wheelText = context.text.titleMedium?.copyWith(
      color: context.colors.onSurface,
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          0,
          WsSpacing.xl,
          WsSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: context.text.titleLarge),
            const SizedBox(height: WsSpacing.xs),
            _SelectedDate(value: _value, today: widget.maximum),
            const SizedBox(height: WsSpacing.lg),
            SizedBox(
              height: _wheelHeight,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Theme.of(context).brightness,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: wheelText,
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  dateOrder: DatePickerDateOrder.mdy,
                  initialDateTime: widget.initial,
                  minimumDate: widget.minimum,
                  maximumDate: widget.maximum,
                  onDateTimeChanged: (d) => setState(() => _value = d),
                ),
              ),
            ),
            const SizedBox(height: WsSpacing.xl),
            WsPrimaryButton(
              label: 'Done',
              forward: false,
              onPressed: () => Navigator.of(context).pop(_value),
            ),
          ],
        ),
      ),
    );
  }
}

/// The chosen date spelled out, with the age it makes — cross-fading as the
/// wheels turn so the reader sees what they are about to confirm.
class _SelectedDate extends StatelessWidget {
  const _SelectedDate({required this.value, required this.today});

  final DateTime value;
  final DateTime today;

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  int get _age {
    var years = today.year - value.year;
    final birthdayPassed = today.month > value.month ||
        (today.month == value.month && today.day >= value.day);
    if (!birthdayPassed) years -= 1;
    return years;
  }

  @override
  Widget build(BuildContext context) {
    final label = '${value.day} ${_months[value.month - 1]} ${value.year}';
    final age = _age;
    final ageLabel = age == 1 ? '1 year old' : '$age years old';

    return AnimatedSwitcher(
      duration: WsMotion.duration(context, WsMotion.fast),
      switchInCurve: WsMotion.standard,
      switchOutCurve: WsMotion.exit,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.25),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.centerLeft,
        children: [...previous, if (current != null) current],
      ),
      child: Text(
        '$label · $ageLabel',
        key: ValueKey(label),
        style: context.text.bodyMedium?.copyWith(color: context.ws.caption),
      ),
    );
  }
}
