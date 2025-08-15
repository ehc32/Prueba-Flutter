import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/task_invitation.dart';
import '../../../../core/providers/auth_provider.dart';

final invitationsProvider = StateNotifierProvider<InvitationsNotifier, InvitationsState>((ref) {
  final authState = ref.watch(authProvider);
  return InvitationsNotifier(authState.user?.id, authState.user?.email);
});

class InvitationsNotifier extends StateNotifier<InvitationsState> {
  final String? userId;
  final String? userEmail;
  final SupabaseClient _supabase = Supabase.instance.client;

  InvitationsNotifier(this.userId, this.userEmail) : super(InvitationsState.initial()) {
    if (userId != null) {
      loadInvitations();
    }
  }

  Future<void> loadInvitations() async {
    if (userId == null) return;

    try {
      state = state.copyWith(isLoading: true);
      
      // Cargar invitaciones enviadas
      final sentResponse = await _supabase
          .from('task_invitations')
          .select()
          .eq('from_user_id', userId!)
          .order('created_at', ascending: false);

      final sentInvitations = (sentResponse as List)
          .map((json) => TaskInvitation.fromJson(json))
          .toList();

      // Cargar invitaciones recibidas
      final receivedResponse = await _supabase
          .from('task_invitations')
          .select()
          .eq('to_user_email', userEmail!)
          .order('created_at', ascending: false);

      final receivedInvitations = (receivedResponse as List)
          .map((json) => TaskInvitation.fromJson(json))
          .toList();

      state = state.copyWith(
        sentInvitations: sentInvitations,
        receivedInvitations: receivedInvitations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendInvitation(String taskId, String taskTitle, String toUserEmail) async {
    if (userId == null || userEmail == null) return;

    try {
      state = state.copyWith(isLoading: true);

      final response = await _supabase
          .from('task_invitations')
          .insert({
            'task_id': taskId,
            'task_title': taskTitle,
            'from_user_id': userId!,
            'from_user_email': userEmail!,
            'to_user_email': toUserEmail,
            'is_accepted': false,
            'is_declined': false,
          })
          .select()
          .single();

      final newInvitation = TaskInvitation.fromJson(response);
      state = state.copyWith(
        sentInvitations: [newInvitation, ...state.sentInvitations],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    try {
      state = state.copyWith(isLoading: true);

      await _supabase
          .from('task_invitations')
          .update({
            'is_accepted': true,
            'is_declined': false,
          })
          .eq('id', invitationId);

      final updatedInvitations = state.receivedInvitations.map((invitation) {
        return invitation.id == invitationId 
            ? invitation.copyWith(isAccepted: true, isDeclined: false)
            : invitation;
      }).toList();

      state = state.copyWith(
        receivedInvitations: updatedInvitations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> declineInvitation(String invitationId) async {
    try {
      state = state.copyWith(isLoading: true);

      await _supabase
          .from('task_invitations')
          .update({
            'is_accepted': false,
            'is_declined': true,
          })
          .eq('id', invitationId);

      final updatedInvitations = state.receivedInvitations.map((invitation) {
        return invitation.id == invitationId 
            ? invitation.copyWith(isAccepted: false, isDeclined: true)
            : invitation;
      }).toList();

      state = state.copyWith(
        receivedInvitations: updatedInvitations,
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

class InvitationsState {
  final List<TaskInvitation> sentInvitations;
  final List<TaskInvitation> receivedInvitations;
  final bool isLoading;
  final String? error;

  InvitationsState({
    required this.sentInvitations,
    required this.receivedInvitations,
    required this.isLoading,
    this.error,
  });

  factory InvitationsState.initial() => InvitationsState(
        sentInvitations: [],
        receivedInvitations: [],
        isLoading: false,
      );

  InvitationsState copyWith({
    List<TaskInvitation>? sentInvitations,
    List<TaskInvitation>? receivedInvitations,
    bool? isLoading,
    String? error,
  }) {
    return InvitationsState(
      sentInvitations: sentInvitations ?? this.sentInvitations,
      receivedInvitations: receivedInvitations ?? this.receivedInvitations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  List<TaskInvitation> get pendingReceivedInvitations => 
      receivedInvitations.where((invitation) => !invitation.isAccepted && !invitation.isDeclined).toList();
}
