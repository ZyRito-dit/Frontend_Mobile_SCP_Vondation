import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../api_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<UserModel?> getMe();
  Future<UserModel> upgradeClearance(int targetLevel);
  Future<UserModel> topUpCredits(int amount);
  Future<void> logout();
  Future<String?> getToken();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  static const String tokenKey = 'scp_auth_token';

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  Map<String, String> _headers([String? token]) {
    final headers = {
      'ngrok-skip-browser-warning': 'true',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final authToken = token ?? sharedPreferences.getString(tokenKey);
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(tokenKey);
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('${ApiService.baseUrl}/login');
    final response = await client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final token = data['access_token']?.toString();
      if (token != null) {
        await sharedPreferences.setString(tokenKey, token);
      }
      return {
        'user': UserModel.fromJson(data['user']),
        'token': token,
      };
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final uri = Uri.parse('${ApiService.baseUrl}/register');
    final response = await client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final token = data['access_token']?.toString();
      if (token != null) {
        await sharedPreferences.setString(tokenKey, token);
      }
      return {
        'user': UserModel.fromJson(data['user']),
        'token': token,
      };
    } else {
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  @override
  Future<UserModel?> getMe() async {
    final token = sharedPreferences.getString(tokenKey);
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse('${ApiService.baseUrl}/me');
    final response = await client.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data['user']);
    } else {
      await sharedPreferences.remove(tokenKey);
      return null;
    }
  }

  @override
  Future<UserModel> upgradeClearance(int targetLevel) async {
    final uri = Uri.parse('${ApiService.baseUrl}/clearance/upgrade');
    final response = await client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'target_level': targetLevel,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception(data['message'] ?? 'Failed to upgrade clearance');
    }
  }

  @override
  Future<UserModel> topUpCredits(int amount) async {
    final uri = Uri.parse('${ApiService.baseUrl}/credits/topup');
    final response = await client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'amount': amount,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception(data['message'] ?? 'Top-up failed');
    }
  }

  @override
  Future<void> logout() async {
    final token = sharedPreferences.getString(tokenKey);
    if (token != null) {
      try {
        final uri = Uri.parse('${ApiService.baseUrl}/logout');
        await client.post(uri, headers: _headers(token));
      } catch (_) {}
    }
    await sharedPreferences.remove(tokenKey);
  }
}
