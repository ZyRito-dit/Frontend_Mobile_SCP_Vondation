import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_data_source.dart';

abstract class AuthRepository {
  Future<UserEntity?> checkAuthStatus();
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String name, String email, String password);
  Future<UserEntity> upgradeClearance(int targetLevel);
  Future<UserEntity> topUpCredits(int amount);
  Future<void> logout();
}

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity?> checkAuthStatus() async {
    return await remoteDataSource.getMe();
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    final result = await remoteDataSource.login(email, password);
    return result['user'] as UserEntity;
  }

  @override
  Future<UserEntity> register(String name, String email, String password) async {
    final result = await remoteDataSource.register(name, email, password);
    return result['user'] as UserEntity;
  }

  @override
  Future<UserEntity> upgradeClearance(int targetLevel) async {
    return await remoteDataSource.upgradeClearance(targetLevel);
  }

  @override
  Future<UserEntity> topUpCredits(int amount) async {
    return await remoteDataSource.topUpCredits(amount);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }
}
