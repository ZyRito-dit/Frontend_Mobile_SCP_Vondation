import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.clearanceLevel,
    required super.agentId,
    required super.credits,
    super.clearanceExpiresAt,
    super.daysRemaining,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] is int) ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'SCP Agent',
      email: json['email']?.toString() ?? '',
      clearanceLevel: (json['clearance_level'] is int)
          ? json['clearance_level']
          : int.tryParse(json['clearance_level']?.toString() ?? '1') ?? 1,
      agentId: json['agent_id']?.toString() ?? 'AGENT-SCP-0000',
      credits: (json['credits'] is int)
          ? json['credits']
          : int.tryParse(json['credits']?.toString() ?? '0') ?? 0,
      clearanceExpiresAt: json['clearance_expires_at']?.toString(),
      daysRemaining: (json['days_remaining'] is int)
          ? json['days_remaining']
          : int.tryParse(json['days_remaining']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'clearance_level': clearanceLevel,
      'agent_id': agentId,
      'credits': credits,
      'clearance_expires_at': clearanceExpiresAt,
      'days_remaining': daysRemaining,
    };
  }
}
