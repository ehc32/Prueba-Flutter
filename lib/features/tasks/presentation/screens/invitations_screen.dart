import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/invitations_provider.dart';
import '../widgets/invitation_card.dart';

class InvitationsScreen extends ConsumerWidget {
  const InvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationsState = ref.watch(invitationsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text(
            'Mis Invitaciones',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Recibidas'),
              Tab(text: 'Enviadas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReceivedInvitations(context, ref, invitationsState),
            _buildSentInvitations(context, ref, invitationsState),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedInvitations(
    BuildContext context,
    WidgetRef ref,
    invitationsState,
  ) {
    if (invitationsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (invitationsState.receivedInvitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay invitaciones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando recibas invitaciones aparecerán aquí',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invitationsState.receivedInvitations.length,
      itemBuilder: (context, index) {
        final invitation = invitationsState.receivedInvitations[index];
        return Padding(
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
        );
      },
    );
  }

  Widget _buildSentInvitations(
    BuildContext context,
    WidgetRef ref,
    invitationsState,
  ) {
    if (invitationsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (invitationsState.sentInvitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No has enviado invitaciones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Invita a otros a colaborar en tus tareas',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/tasks'),
              icon: const Icon(Icons.add),
              label: const Text('Ir a Tareas'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invitationsState.sentInvitations.length,
      itemBuilder: (context, index) {
        final invitation = invitationsState.sentInvitations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSentInvitationCard(context, invitation),
        );
      },
    );
  }

  Widget _buildSentInvitationCard(BuildContext context, invitation) {
    String statusText;
    Color statusColor;

    if (invitation.isAccepted) {
      statusText = 'Aceptada';
      statusColor = Colors.green;
    } else if (invitation.isDeclined) {
      statusText = 'Rechazada';
      statusColor = Colors.red;
    } else {
      statusText = 'Pendiente';
      statusColor = Colors.orange;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Invitación Enviada',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              invitation.taskTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Para: ${invitation.toUserEmail}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fecha: ${_formatDate(invitation.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
