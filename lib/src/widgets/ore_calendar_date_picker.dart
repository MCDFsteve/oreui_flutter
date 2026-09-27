import 'package:flutter/material.dart';
import '../theme/ore_theme.dart';
import 'ore_button.dart';
import 'ore_dropdown_button.dart';
import 'ore_icon_button.dart';

/// Month/year navigation and a bounded date grid, using Ore controls throughout.
class OreCalendarDatePicker extends StatefulWidget {
  const OreCalendarDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    this.rangeStart,
    this.rangeEnd,
  });
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateChanged;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  @override
  State<OreCalendarDatePicker> createState() => _OreCalendarDatePickerState();
}

class _OreCalendarDatePickerState extends State<OreCalendarDatePicker> {
  late DateTime _month;
  late DateTime _selected;
  DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime get _first => _date(widget.firstDate);
  DateTime get _last => _date(widget.lastDate);
  DateTime _clamp(DateTime d) => d.isBefore(_first)
      ? _first
      : d.isAfter(_last)
      ? _last
      : d;

  @override
  void initState() {
    super.initState();
    assert(!_date(widget.lastDate).isBefore(_date(widget.firstDate)));
    _selected = _clamp(_date(widget.initialDate));
    _month = DateTime(_selected.year, _selected.month);
  }

  @override
  void didUpdateWidget(OreCalendarDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.firstDate != oldWidget.firstDate ||
        widget.lastDate != oldWidget.lastDate) {
      _selected = _clamp(_selected);
      _showMonth(_month);
    }
  }

  void _showMonth(DateTime date) {
    final next = _clamp(date);
    setState(() => _month = DateTime(next.year, next.month));
  }

  bool _same(DateTime? a, DateTime b) => a != null && _date(a) == b;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final theme = OreTheme.of(context);
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final firstWeekday = localizations.firstDayOfWeekIndex;
    final offset = (_month.weekday % 7 - firstWeekday + 7) % 7;
    final previous = DateTime(_month.year, _month.month, 0);
    final next = DateTime(_month.year, _month.month + 1);
    final firstMonth = _month.year == _first.year ? _first.month : 1;
    final lastMonth = _month.year == _last.year ? _last.month : 12;
    final now = _date(DateTime.now());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            OreIconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: '上个月',
              onPressed: previous.isBefore(_first)
                  ? null
                  : () => _showMonth(previous),
            ),
            Expanded(
              child: OreDropdownButton<int>(
                value: _month.year,
                size: OreButtonSize.sm,
                fullWidth: true,
                items: [
                  for (var y = _first.year; y <= _last.year; y++)
                    OreDropdownItem(value: y, child: Text('$y')),
                ],
                onChanged: (year) => _showMonth(DateTime(year, _month.month)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OreDropdownButton<int>(
                value: _month.month,
                size: OreButtonSize.sm,
                fullWidth: true,
                items: [
                  for (var m = firstMonth; m <= lastMonth; m++)
                    OreDropdownItem(value: m, child: Text('$m 月')),
                ],
                onChanged: (month) => _showMonth(DateTime(_month.year, month)),
              ),
            ),
            OreIconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: '下个月',
              onPressed: next.isAfter(_last) ? null : () => _showMonth(next),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    localizations.narrowWeekdays[(i + firstWeekday) % 7],
                    style: theme.typography.caption,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (var week = 0; week < (offset + days + 6) ~/ 7; week++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                for (var weekday = 0; weekday < 7; weekday++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _day(
                        context,
                        week * 7 + weekday - offset + 1,
                        days,
                        now,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _day(BuildContext context, int day, int days, DateTime now) {
    if (day < 1 || day > days) return const SizedBox.shrink();
    final date = DateTime(_month.year, _month.month, day);
    final enabled = !date.isBefore(_first) && !date.isAfter(_last);
    final range = widget.rangeStart != null;
    final selected = range
        ? _same(widget.rangeStart, date) || _same(widget.rangeEnd, date)
        : _same(_selected, date);
    final inside =
        widget.rangeStart != null &&
        widget.rangeEnd != null &&
        date.isAfter(_date(widget.rangeStart!)) &&
        date.isBefore(_date(widget.rangeEnd!));
    return Semantics(
      label: MaterialLocalizations.of(context).formatFullDate(date),
      selected: selected,
      child: OreButton(
        key: ValueKey('ore-date-${date.year}-${date.month}-$day'),
        size: OreButtonSize.sm,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        variant: selected
            ? OreButtonVariant.primary
            : OreButtonVariant.secondary,
        forcePressed: inside,
        forcePressedKeepsColor: true,
        onPressed: enabled
            ? () {
                setState(() => _selected = date);
                widget.onDateChanged(date);
              }
            : null,
        child: Text(
          '$day',
          style: TextStyle(
            decoration: date == now ? TextDecoration.underline : null,
            fontWeight: inside ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }
}
