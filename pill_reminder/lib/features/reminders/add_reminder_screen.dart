import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';
import '../../models/reminder.dart';
import '../../providers/app_providers.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  final Reminder? reminder;

  const AddReminderScreen({super.key, this.reminder});

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  List<MedicineFormData> _medicines = [];

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
      _medicines = widget.reminder!.medicines.map((m) => MedicineFormData(
        id: m.id,
        nameController: TextEditingController(text: m.name),
        doseController: TextEditingController(text: m.dose),
        unit: m.unit,
      )).toList();

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

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Reminder' : 'Add Reminder',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1976D2),
        actions: isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteReminder,
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTimePicker(),
              const SizedBox(height: 16),
              _buildSchedulePicker(),
              const SizedBox(height: 24),
              _buildMedicinesList(),
              const SizedBox(height: 24),
              _buildAddMedicineButton(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditing ? 'Update Reminder' : 'Save Reminder',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.access_time, color: Color(0xFF1976D2)),
        title: const Text(
          'Reminder Time',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_formatTime(_selectedTime)),
        trailing: const Icon(Icons.chevron_right),
        onTap: _pickTime,
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
              value: _scheduleType,
              decoration: const InputDecoration(
                labelText: 'Reminder runs',
                border: OutlineInputBorder(),
              ),
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
                leading: const Icon(Icons.event, color: Color(0xFF1976D2)),
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
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_scheduleType != ReminderScheduleType.forDays) return null;
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
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
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
                border: const OutlineInputBorder(),
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
                      border: const OutlineInputBorder(),
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
                    value: medicine.unit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    items: ['mg', 'ml', 'tablet', 'capsule', 'drop'].map((unit) {
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
        foregroundColor: const Color(0xFF1976D2),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
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

    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine')),
      );
      return;
    }

    final reminderMedicines = _medicines.map((m) => ReminderMedicine(
      id: m.id,
      name: m.nameController.text.trim(),
      dose: m.doseController.text.trim(),
      unit: m.unit,
    )).toList();

    final reminder = Reminder(
      id: widget.reminder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      time: _formatTime(_selectedTime),
      medicines: reminderMedicines,
      scheduleType: _scheduleType == ReminderScheduleType.dailyForever
          ? 0
          : (_scheduleType == ReminderScheduleType.untilDate ? 1 : 2),
      startDate: widget.reminder?.startDate ?? _startDate,
      endDate: _scheduleType == ReminderScheduleType.untilDate ? _endDate : null,
      durationDays: _scheduleType == ReminderScheduleType.forDays
          ? int.tryParse(_durationDaysController.text.trim())
          : null,
    );

    final granted = await NotificationService.requestPermissions();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications are disabled. Enable them to receive reminders.'),
        ),
      );
    }

    if (widget.reminder != null) {
      await ref.read(remindersProvider.notifier).updateReminder(reminder);
    } else {
      await ref.read(remindersProvider.notifier).addReminder(reminder);
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
              await ref.read(remindersProvider.notifier).deleteReminder(widget.reminder!.id);
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
