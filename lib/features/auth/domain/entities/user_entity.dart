import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final int clearanceLevel;
  final String agentId;
  final int credits;
  final String? clearanceExpiresAt;
  final int daysRemaining;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.clearanceLevel,
    required this.agentId,
    required this.credits,
    this.clearanceExpiresAt,
    this.daysRemaining = 0,
  });

  String get clearanceTitle {
    switch (clearanceLevel) {
      case 1:
        return 'Level 1 - Safe / Restricted';
      case 2:
        return 'Level 2 - Euclid Clearance';
      case 3:
        return 'Level 3 - Keter Clearance';
      case 4:
        return 'Level 4 - Thaumiel / O5 Executive';
      default:
        return 'Level 1 - Restricted';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        clearanceLevel,
        agentId,
        credits,
        clearanceExpiresAt,
        daysRemaining,
      ];
}
