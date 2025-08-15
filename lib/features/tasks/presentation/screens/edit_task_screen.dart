import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/tasks_provider.dart';
import '../../domain/models/task.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final String taskId;

  const EditTaskScreen({
    super.key,
    required this.taskId,
  });

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _hasDueDate = false;
  bool _isCompleted = false;
  Task? _task;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadTask() {
    final tasksState = ref.read(tasksProvider);
    final task = tasksState.tasks.firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () => throw Exception('Tarea no encontrada'),
    );

    setState(() {
      _task = task;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _isCompleted = task.isCompleted;
      _hasDueDate = task.dueDate != null;
      _selectedDate = task.dueDate;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate() && _task != null) {
      final updatedTask = _task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        isCompleted: _isCompleted,
        dueDate: _hasDueDate ? _selectedDate : null,
      );

      await ref.read(tasksProvider.notifier).updateTask(updatedTask);
      
      if (mounted) {
        context.go('/tasks');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);

    if (_task == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarea'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          if (tasksState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado de completado
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isCompleted,
                        onChanged: (value) {
                          setState(() {
                            _isCompleted = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Marcar como completada',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                'Título',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ingresa el título de la tarea',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Descripción
              Text(
                'Descripción',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ingresa una descripción (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 24),

              // Fecha de vencimiento
              Row(
                children: [
                  Checkbox(
                    value: _hasDueDate,
                    onChanged: (value) {
                      setState(() {
                        _hasDueDate = value ?? false;
                        if (!_hasDueDate) {
                          _selectedDate = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Establecer fecha de vencimiento',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (_hasDueDate) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Seleccionar fecha',
                          style: TextStyle(
                            color: _selectedDate != null
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Botón de actualizar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: tasksState.isLoading ? null : _updateTask,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Actualizar Tarea',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
