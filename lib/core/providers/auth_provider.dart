import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClient = Supabase.instance.client;

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _init();
  }

  void _init() {
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      state = AuthState.authenticated(user);
    }

    supabaseClient.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final User? user = data.session?.user;

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (user != null) {
            state = AuthState.authenticated(user);
          }
          break;
        case AuthChangeEvent.signedOut:
          state = AuthState.unauthenticated();
          break;
        default:
          break;
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = AuthState.loading();
      await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = AuthState.loading();
      await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({
    required this.isLoading,
    this.user,
    this.error,
  });

  factory AuthState.initial() => AuthState(isLoading: false);
  factory AuthState.loading() => AuthState(isLoading: true);
  factory AuthState.authenticated(User user) => AuthState(
        isLoading: false,
        user: user,
      );
  factory AuthState.unauthenticated() => AuthState(isLoading: false);
  factory AuthState.error(String error) => AuthState(
        isLoading: false,
        error: error,
      );

  bool get isAuthenticated => user != null;
}
