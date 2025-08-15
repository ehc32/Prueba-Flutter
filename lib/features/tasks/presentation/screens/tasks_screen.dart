import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/providers/auth_provider.dart';
import '../providers/tasks_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_stats_card.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  void initState() {
    super.initState();
    // Verificar autenticación al cargar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (!authState.isAuthenticated) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final tasksState = ref.watch(tasksProvider);

    // Redirigir si no está autenticado
    if (!authState.isAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Mis Tareas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
            tooltip: 'Mi Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.mail),
            onPressed: () => context.go('/invitations'),
            tooltip: 'Invitaciones',
          ),
        ],
      ),
      body: Column(
        children: [
          // Estadísticas
          if (tasksState.tasks.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TaskStatsCard(
                      title: 'Pendientes',
                      count: tasksState.pendingTasks.length,
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TaskStatsCard(
                      title: 'Completadas',
                      count: tasksState.completedTasks.length,
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

          // Lista de tareas
          Expanded(
            child: tasksState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tasksState.tasks.isEmpty
                    ? _buildEmptyState()
                    : _buildTasksList(tasksState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/add-task'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Tarea'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay tareas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera tarea para comenzar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/add-task'),
            icon: const Icon(Icons.add),
            label: const Text('Crear Tarea'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(TasksState tasksState) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasksState.tasks.length,
      itemBuilder: (context, index) {
        final task = tasksState.tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                                 SlidableAction(
                   onPressed: (_) => _inviteUser(task),
                   backgroundColor: Colors.purple,
                   foregroundColor: Colors.white,
                   icon: Icons.person_add,
                   label: 'Invitar',
                   borderRadius: const BorderRadius.horizontal(
                     left: Radius.circular(12),
                   ),
                 ),
                 SlidableAction(
                   onPressed: (_) => _editTask(task),
                   backgroundColor: Colors.blue,
                   foregroundColor: Colors.white,
                   icon: Icons.edit,
                   label: 'Editar',
                 ),
                 SlidableAction(
                   onPressed: (_) => _deleteTask(task.id),
                   backgroundColor: Colors.red,
                   foregroundColor: Colors.white,
                   icon: Icons.delete,
                   label: 'Eliminar',
                   borderRadius: const BorderRadius.horizontal(
                     right: Radius.circular(12),
                   ),
                 ),
              ],
            ),
            child: TaskCard(
              task: task,
              onToggle: () => ref.read(tasksProvider.notifier).toggleTaskCompletion(task.id),
              onTap: () => _editTask(task),
            ),
          ),
        );
      },
    );
  }

  void _editTask(task) {
    context.go('/edit-task/${task.id}');
  }

  void _inviteUser(task) {
    context.push('/invite-user', extra: task);
  }

  void _deleteTask(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarea'),
        content: const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(taskId);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
