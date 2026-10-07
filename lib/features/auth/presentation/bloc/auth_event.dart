import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {}

class LoginAuthEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginAuthEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterAuthEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterAuthEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class UpgradeClearanceEvent extends AuthEvent {
  final int targetLevel;

  const UpgradeClearanceEvent(this.targetLevel);

  @override
  List<Object?> get props => [targetLevel];
}

class TopUpCreditsEvent extends AuthEvent {
  final int amount;

  const TopUpCreditsEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class LogoutAuthEvent extends AuthEvent {}
