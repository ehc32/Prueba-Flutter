import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../../tasks/presentation/providers/invitations_provider.dart';
import '../../../tasks/presentation/widgets/invitation_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final tasksState = ref.watch(tasksProvider);
    final invitationsState = ref.watch(invitationsProvider);

    if (!authState.isAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = authState.user!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = GoRouter.of(context);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                navigator.go('/login');
              }
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del usuario
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.email ?? 'Usuario',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                                         Text(
                       'Miembro desde ${_formatDate(DateTime.parse(user.createdAt))}',
                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                         color: Theme.of(context).colorScheme.onSurfaceVariant,
                       ),
                     ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Estadísticas
            Text(
              'Estadísticas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Tareas',
                    tasksState.tasks.length.toString(),
                    Icons.task_alt,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Completadas',
                    tasksState.completedTasks.length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Pendientes',
                    tasksState.pendingTasks.length.toString(),
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Invitaciones',
                    invitationsState.pendingReceivedInvitations.length.toString(),
                    Icons.mail,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Invitaciones pendientes
            if (invitationsState.pendingReceivedInvitations.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invitaciones Pendientes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/invitations'),
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...invitationsState.pendingReceivedInvitations
                  .take(3)
                  .map((invitation) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InvitationCard(
                          invitation: invitation,
                          onAccept: () => ref
                              .read(invitationsProvider.notifier)
                              .acceptInvitation(invitation.id),
                          onDecline: () => ref
                              .read(invitationsProvider.notifier)
                              .declineInvitation(invitation.id),
                        ),
                      )),
            ],

            const SizedBox(height: 32),

            // Acciones rápidas
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActionCard(
              context,
              'Nueva Tarea',
              'Crear una nueva tarea',
              Icons.add_task,
              () => context.go('/add-task'),
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              context,
              'Mis Invitaciones',
              'Ver todas las invitaciones',
              Icons.mail_outline,
              () => context.go('/invitations'),
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              context,
              'Configuración',
              'Ajustes de la aplicación',
              Icons.settings,
              () {
                // TODO: Implementar pantalla de configuración
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuración próximamente')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
