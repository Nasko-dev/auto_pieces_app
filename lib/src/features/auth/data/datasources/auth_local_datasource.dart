import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  // Simulation d'un stockage local simple
  // En production, utilisez shared_preferences ou hive
  static UserModel? _cachedUser;

  @override
  Future<UserModel?> getCachedUser() async {
    return _cachedUser;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    _cachedUser = user;
    if (kDebugMode) {
    }
  }

  @override
  Future<void> clearCache() async {
    _cachedUser = null;
    if (kDebugMode) {
    }
  }
}