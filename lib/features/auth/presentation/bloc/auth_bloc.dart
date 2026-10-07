import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthState()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginAuthEvent>(_onLogin);
    on<RegisterAuthEvent>(_onRegister);
    on<UpgradeClearanceEvent>(_onUpgradeClearance);
    on<TopUpCreditsEvent>(_onTopUpCredits);
    on<LogoutAuthEvent>(_onLogout);
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await authRepository.checkAuthStatus();
      if (user != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
      }
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    }
  }

  Future<void> _onLogin(
    LoginAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        successMessage: 'Akses Diberikan: Selamat Datang Agent ${user.name}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRegister(
    RegisterAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await authRepository.register(event.name, event.email, event.password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        successMessage: 'Registrasi Berhasil: Agent ID ${user.agentId}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpgradeClearance(
    UpgradeClearanceEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final updatedUser = await authRepository.upgradeClearance(event.targetLevel);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
        successMessage: 'Pangkat Berhasil Ditingkatkan ke Level ${updatedUser.clearanceLevel}!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: currentUser,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onTopUpCredits(
    TopUpCreditsEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final updatedUser = await authRepository.topUpCredits(event.amount);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
        successMessage: 'Top Up Berhasil! +${event.amount} Foundation Credits Added.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: currentUser,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLogout(
    LogoutAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await authRepository.logout();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      successMessage: 'Sesi Diakhiri',
    ));
  }
}
