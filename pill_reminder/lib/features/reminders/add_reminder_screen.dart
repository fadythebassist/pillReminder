import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/services/notification_service.dart';
import '../../models/reminder.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_background.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  final Reminder? reminder;

  const AddReminderScreen({super.key, this.reminder});

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  final List<TimeOfDay> _selectedTimes = [];
  List<MedicineFormData> _medicines = [];

  // When editing an existing reminder, keep track of which selected time
  // represents the reminder being edited (by its original HH:mm key).
  String? _editingBaseTimeKey;

  ReminderScheduleType _scheduleType = ReminderScheduleType.dailyForever;
  DateTime _startDate = _todayLocalDate();
  DateTime? _endDate;
  final _durationDaysController = TextEditingController(text: '7');

  static DateTime _todayLocalDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _selectedTime = TimeOfDay(
        hour: int.parse(widget.reminder!.time.split(':')[0]),
        minute: int.parse(widget.reminder!.time.split(':')[1]),
      );

      _editingBaseTimeKey = widget.reminder!.time;
      _selectedTimes
        ..clear()
        ..add(_parseTimeOfDay(widget.reminder!.time));

      _medicines = widget.reminder!.medicines
          .map((m) => MedicineFormData(
                id: m.id,
                nameController: TextEditingController(text: m.name),
                doseController: TextEditingController(text: m.dose),
                unit: m.unit,
              ))
          .toList();

      _scheduleType = widget.reminder!.schedule;
      _startDate = DateTime(
        widget.reminder!.startDate.year,
        widget.reminder!.startDate.month,
        widget.reminder!.startDate.day,
      );
      _endDate = widget.reminder!.endDate;
      if (widget.reminder!.durationDays != null) {
        _durationDaysController.text = widget.reminder!.durationDays.toString();
      }
    } else {
      _selectedTimes
        ..clear()
        ..add(_selectedTime);
      _medicines = [
        MedicineFormData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nameController: TextEditingController(),
          doseController: TextEditingController(),
          unit: 'mg',
        ),
      ];
    }
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _dedupeAndSortTimes() {
    final seen = <String>{};
    final next = <TimeOfDay>[];
    for (final t in _selectedTimes) {
      final key = _formatTimeKey(t);
      if (seen.add(key)) {
        next.add(t);
      }
    }
    next.sort((a, b) => _formatTimeKey(a).compareTo(_formatTimeKey(b)));
    _selectedTimes
      ..clear()
      ..addAll(next);
  }

  @override
  void dispose() {
    for (var med in _medicines) {
      med.nameController.dispose();
      med.doseController.dispose();
    }
    _durationDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Reminder' : 'Add Reminder',
        ),
        actions: isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.add_alarm),
                  onPressed: _addTime,
                  tooltip: 'Add reminder time',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteReminder,
                  tooltip: 'Delete reminder',
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.add_alarm),
                  onPressed: _addTime,
                  tooltip: 'Add reminder time',
                ),
              ],
      ),
      body: SafeArea(
        child: AppBackground(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _buildTimePicker(isEditing: isEditing),
                const SizedBox(height: 16),
                _buildSchedulePicker(),
                const SizedBox(height: 16),
                _buildLockoutPicker(),
                const SizedBox(height: 24),
                _buildMedicinesList(),
                const SizedBox(height: 16),
                _buildAddMedicineButton(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saveReminder,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: scheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        Text(isEditing ? 'Update Reminder' : 'Save Reminder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker({required bool isEditing}) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final times = _selectedTimes.toList()
      ..sort((a, b) => _formatTimeKey(a).compareTo(_formatTimeKey(b)));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEditing ? 'Reminder Times' : 'Reminder Times',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _addTime,
                  icon: const Icon(Icons.add),
                  label: const Text('Add time'),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (times.isEmpty)
              Text(
                'Add one or more times',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: times.map((t) {
                      final key = _formatTimeKey(t);
                      final isBase =
                          widget.reminder != null && key == _editingBaseTimeKey;
                      return InputChip(
                        label: Text(_formatTimeDisplay(t)),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: isBase ? null : () => _removeTime(key),
                        onPressed: () => _editTime(key),
                        side: BorderSide(
                            color: scheme.primary.withValues(alpha: 0.16)),
                        backgroundColor: Colors.white,
                        labelStyle: textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tip: tap a time to edit it',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulePicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ReminderScheduleType>(
              initialValue: _scheduleType,
              decoration: const InputDecoration(labelText: 'Reminder runs'),
              items: const [
                DropdownMenuItem(
                  value: ReminderScheduleType.dailyForever,
                  child: Text('Every day (no end)'),
                ),
                DropdownMenuItem(
                  value: ReminderScheduleType.untilDate,
                  child: Text('Until a date'),
                ),
                DropdownMenuItem(
                  value: ReminderScheduleType.forDays,
                  child: Text('For a number of days'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _scheduleType = value;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_scheduleType == ReminderScheduleType.untilDate)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.event,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text('End date'),
                subtitle: Text(_endDate == null
                    ? 'Tap to choose'
                    : '${_endDate!.year.toString().padLeft(4, '0')}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickEndDate,
              ),
            if (_scheduleType == ReminderScheduleType.forDays)
              TextFormField(
                controller: _durationDaysController,
                decoration: const InputDecoration(
                  labelText: 'Number of days',
                  hintText: 'e.g., 10',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_scheduleType != ReminderScheduleType.forDays)
                    return null;
                  final parsed = int.tryParse((value ?? '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid number of days';
                  }
                  if (parsed > 365) {
                    return 'Please use 365 days or fewer';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockoutPicker() {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final lockoutMinutes = ref.watch(lockoutMinutesProvider);
    final displayDuration = _formatDuration(lockoutMinutes);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lockout duration',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  displayDuration,
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Prevents taking the same medicine again within this time after marking a dose as taken.',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Off'),
                  selected: lockoutMinutes == 0,
                  onSelected: (_) {
                    ref.read(lockoutMinutesProvider.notifier).setMinutes(0);
                  },
                  selectedColor: scheme.primary.withValues(alpha: 0.18),
                  labelStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: lockoutMinutes == 0 ? scheme.primary : null,
                  ),
                  side: BorderSide(
                    color: scheme.primary
                        .withValues(alpha: lockoutMinutes == 0 ? 0.35 : 0.16),
                  ),
                ),
                ...AppConstants.lockoutPresetMinutes.map((minutes) {
                  final selected = lockoutMinutes == minutes;
                  final hours = minutes ~/ 60;
                  return ChoiceChip(
                    label: Text('${hours}h'),
                    selected: selected,
                    onSelected: (_) {
                      ref
                          .read(lockoutMinutesProvider.notifier)
                          .setMinutes(minutes);
                    },
                    selectedColor: scheme.primary.withValues(alpha: 0.18),
                    labelStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? scheme.primary : null,
                    ),
                    side: BorderSide(
                      color: scheme.primary
                          .withValues(alpha: selected ? 0.35 : 0.16),
                    ),
                  );
                }),
                ActionChip(
                  label: const Text('Custom'),
                  onPressed: () => _pickCustomLockoutDuration(lockoutMinutes),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int totalMinutes) {
    if (totalMinutes <= 0) return 'Off';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  Future<void> _pickCustomLockoutDuration(int currentMinutes) async {
    final initialMinutes = currentMinutes.clamp(0, 23 * 60 + 59);
    final initial = TimeOfDay(
      hour: initialMinutes ~/ 60,
      minute: initialMinutes % 60,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Lockout duration',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    await ref.read(lockoutMinutesProvider.notifier).setMinutes(minutes);
  }

  Future<void> _pickEndDate() async {
    final initial = _endDate ?? _startDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Widget _buildMedicinesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicines',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._medicines.asMap().entries.map((entry) {
          final index = entry.key;
          final medicine = entry.value;
          return _buildMedicineCard(medicine, index);
        }),
      ],
    );
  }

  Widget _buildMedicineCard(MedicineFormData medicine, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Medicine ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_medicines.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () => _removeMedicine(index),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: medicine.nameController,
              decoration: InputDecoration(
                labelText: 'Medicine Name',
                hintText: 'e.g., Aspirin, Vitamin D',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter medicine name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: medicine.doseController,
                    decoration: InputDecoration(
                      labelText: 'Dose',
                      hintText: 'e.g., 100',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter dose';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: medicine.unit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    items:
                        ['mg', 'ml', 'tablet', 'capsule', 'drop'].map((unit) {
                      return DropdownMenuItem(value: unit, child: Text(unit));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        medicine.unit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMedicineButton() {
    return OutlinedButton.icon(
      onPressed: _addMedicine,
      icon: const Icon(Icons.add),
      label: const Text('Add Another Medicine'),
      style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12)),
    );
  }

  String _formatTimeKey(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeDisplay(TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: false,
    );
  }

  Future<void> _addTime() async {
    final initial =
        _selectedTimes.isNotEmpty ? _selectedTimes.last : _selectedTime;
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (time == null) return;

    final key = _formatTimeKey(time);
    final existing = _selectedTimes.any((t) => _formatTimeKey(t) == key);
    if (existing) return;

    setState(() {
      _selectedTimes.add(time);
      _dedupeAndSortTimes();
    });
  }

  Future<void> _editTime(String formatted) async {
    final current = _selectedTimes.firstWhere(
      (t) => _formatTimeKey(t) == formatted,
      orElse: () => _selectedTime,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
    );
    if (picked == null) return;

    final newKey = _formatTimeKey(picked);
    final exists = _selectedTimes.any((t) => _formatTimeKey(t) == newKey);
    if (exists) return;

    setState(() {
      final idx =
          _selectedTimes.indexWhere((t) => _formatTimeKey(t) == formatted);
      if (idx >= 0) {
        _selectedTimes[idx] = picked;
      }
      _dedupeAndSortTimes();

      if (widget.reminder != null && _editingBaseTimeKey == formatted) {
        _editingBaseTimeKey = newKey;
      }
    });
  }

  void _removeTime(String formatted) {
    setState(() {
      _selectedTimes.removeWhere((t) => _formatTimeKey(t) == formatted);
    });
  }

  void _addMedicine() {
    setState(() {
      _medicines.add(MedicineFormData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nameController: TextEditingController(),
        doseController: TextEditingController(),
        unit: 'mg',
      ));
    });
  }

  void _removeMedicine(int index) {
    setState(() {
      _medicines[index].nameController.dispose();
      _medicines[index].doseController.dispose();
      _medicines.removeAt(index);
    });
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one reminder time')),
      );
      return;
    }

    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine')),
      );
      return;
    }

    final isEditing = widget.reminder != null;
    final times = _selectedTimes.map(_formatTimeKey).toList()..sort();
    final scheduleTypeValue = _scheduleType == ReminderScheduleType.dailyForever
        ? 0
        : (_scheduleType == ReminderScheduleType.untilDate ? 1 : 2);

    List<ReminderMedicine> buildMedicinesFor(
        Reminder? existing, String reminderId) {
      final form = _medicines
          .map((m) => (
                name: m.nameController.text.trim(),
                dose: m.doseController.text.trim(),
                unit: m.unit,
              ))
          .toList();

      final existingMeds = existing?.medicines ?? const <ReminderMedicine>[];
      final result = <ReminderMedicine>[];

      final sharedCount =
          existingMeds.length < form.length ? existingMeds.length : form.length;
      for (var i = 0; i < sharedCount; i++) {
        result.add(existingMeds[i].copyWith(
          name: form[i].name,
          dose: form[i].dose,
          unit: form[i].unit,
        ));
      }

      for (var i = sharedCount; i < form.length; i++) {
        result.add(ReminderMedicine(
          id: '${reminderId}_med_$i',
          name: form[i].name,
          dose: form[i].dose,
          unit: form[i].unit,
        ));
      }

      return result;
    }

    final granted = await NotificationService.requestPermissions();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Notifications are disabled. Enable them to receive reminders.'),
        ),
      );
    }

    if (!isEditing) {
      final seed = DateTime.now().microsecondsSinceEpoch;
      final remindersToSave = times.map((timeStr) {
        final reminderId = 'rem_${seed}_$timeStr';
        return Reminder(
          id: reminderId,
          time: timeStr,
          medicines: buildMedicinesFor(null, reminderId),
          scheduleType: scheduleTypeValue,
          startDate: _startDate,
          endDate:
              _scheduleType == ReminderScheduleType.untilDate ? _endDate : null,
          durationDays: _scheduleType == ReminderScheduleType.forDays
              ? int.tryParse(_durationDaysController.text.trim())
              : null,
        );
      }).toList();

      await ref.read(remindersProvider.notifier).addReminders(remindersToSave);
    } else {
      final base = widget.reminder!;
      final baseTimeKey = _editingBaseTimeKey ?? base.time;

      // Update the reminder being edited.
      final updated = Reminder(
        id: base.id,
        time: baseTimeKey,
        medicines: buildMedicinesFor(base, base.id),
        scheduleType: scheduleTypeValue,
        startDate: base.startDate,
        endDate:
            _scheduleType == ReminderScheduleType.untilDate ? _endDate : null,
        durationDays: _scheduleType == ReminderScheduleType.forDays
            ? int.tryParse(_durationDaysController.text.trim())
            : null,
      );

      await ref.read(remindersProvider.notifier).updateReminder(updated);

      // Create additional reminders for any extra times the user added.
      final extraTimes = times.where((t) => t != baseTimeKey).toList();
      if (extraTimes.isNotEmpty) {
        var seed = DateTime.now().microsecondsSinceEpoch;
        final extras = extraTimes.map((timeStr) {
          seed += 1;
          final reminderId = 'rem_${seed}_$timeStr';
          return Reminder(
            id: reminderId,
            time: timeStr,
            medicines: buildMedicinesFor(null, reminderId),
            scheduleType: scheduleTypeValue,
            startDate: base.startDate,
            endDate: _scheduleType == ReminderScheduleType.untilDate
                ? _endDate
                : null,
            durationDays: _scheduleType == ReminderScheduleType.forDays
                ? int.tryParse(_durationDaysController.text.trim())
                : null,
          );
        }).toList();

        await ref.read(remindersProvider.notifier).addReminders(extras);
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _deleteReminder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final base = widget.reminder!;
              await ref
                  .read(remindersProvider.notifier)
                  .deleteReminder(base.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class MedicineFormData {
  final String id;
  final TextEditingController nameController;
  final TextEditingController doseController;
  String unit;

  MedicineFormData({
    required this.id,
    required this.nameController,
    required this.doseController,
    required this.unit,
  });
}
