import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import 'package:intl/intl.dart';

class AddEditTodoScreen extends StatefulWidget {
  final TodoModel? todo;
  final DateTime? initialDate;

  const AddEditTodoScreen({super.key, this.todo, this.initialDate});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;

  bool get isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.todo?.description ?? '');
    _selectedDate = widget.todo?.dueDate ?? widget.initialDate ?? DateTime.now();

    if (widget.todo?.dueTime != null) {
      try {
        final timeParts = widget.todo!.dueTime!.split(':');
        if (timeParts.length >= 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      } catch (e) {
        _selectedTime = null;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);

      String? dueTime;
      if (_selectedTime != null) {
        dueTime =
            '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      }

      if (isEditing) {
        final updatedTodo = widget.todo!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _selectedDate,
          dueTime: dueTime,
          updatedAt: DateTime.now(),
        );
        todoProvider.updateTodo(updatedTodo);
      } else {
        final newTodo = TodoModel(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _selectedDate,
          dueTime: dueTime,
        );
        todoProvider.addTodo(newTodo);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Görevi Düzenle' : 'Görev Ekle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen bir başlık girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen bir açıklama girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Bitiş Tarihi'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                leading: const Icon(Icons.calendar_today),
                trailing: const Icon(Icons.edit),
                onTap: _selectDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Bitiş Saati (İsteğe bağlı)'),
                subtitle: Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'Saat belirlenmedi',
                ),
                leading: const Icon(Icons.access_time),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedTime != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedTime = null;
                          });
                        },
                      ),
                    const Icon(Icons.edit),
                  ],
                ),
                onTap: _selectTime,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTodo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isEditing ? 'Görevi Güncelle' : 'Görev Ekle',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
