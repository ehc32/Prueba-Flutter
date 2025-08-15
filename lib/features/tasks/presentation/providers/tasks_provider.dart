import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/task.dart';
import '../../../../core/providers/auth_provider.dart';

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final authState = ref.watch(authProvider);
  return TasksNotifier(authState.user?.id);
});

class TasksNotifier extends StateNotifier<TasksState> {
  final String? userId;
  final SupabaseClient _supabase = Supabase.instance.client;

  TasksNotifier(this.userId) : super(TasksState.initial()) {
    if (userId != null) {
      loadTasks();
    }
  }

  Future<void> loadTasks() async {
    if (userId == null) return;

    try {
      state = state.copyWith(isLoading: true);
      
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId!)
          .order('created_at', ascending: false);

      final tasks = (response as List)
          .map((json) => Task.fromJson(json))
          .toList();

      state = state.copyWith(
        tasks: tasks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addTask(String title, String description, DateTime? dueDate) async {
    if (userId == null) return;

    try {
      state = state.copyWith(isLoading: true);

      final response = await _supabase
          .from('tasks')
          .insert({
            'title': title,
            'description': description,
            'due_date': dueDate?.toIso8601String(),
            'user_id': userId!,
            'is_completed': false,
          })
          .select()
          .single();

      final newTask = Task.fromJson(response);
      state = state.copyWith(
        tasks: [newTask, ...state.tasks],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      state = state.copyWith(isLoading: true);

      await _supabase
          .from('tasks')
          .update({
            'title': task.title,
            'description': task.description,
            'is_completed': task.isCompleted,
            'due_date': task.dueDate?.toIso8601String(),
          })
          .eq('id', task.id);

      final updatedTasks = state.tasks.map((t) {
        return t.id == task.id ? task : t;
      }).toList();

      state = state.copyWith(
        tasks: updatedTasks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = state.tasks.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  Future<void> deleteTask(String taskId) async {
    try {
      state = state.copyWith(isLoading: true);

      await _supabase
          .from('tasks')
          .delete()
          .eq('id', taskId);

      final updatedTasks = state.tasks.where((t) => t.id != taskId).toList();

      state = state.copyWith(
        tasks: updatedTasks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class TasksState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;

  TasksState({
    required this.tasks,
    required this.isLoading,
    this.error,
  });

  factory TasksState.initial() => TasksState(
        tasks: [],
        isLoading: false,
      );

  TasksState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  List<Task> get completedTasks => tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks => tasks.where((task) => !task.isCompleted).toList();
}
