import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginAsParticulier();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl();

  @override
  Future<UserModel> loginAsParticulier() async {
    try {
      // Simulation d'authentification pour les particuliers (sans Supabase)
      await Future.delayed(const Duration(milliseconds: 500));
      
      return UserModel(
        id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        email: null,
        userType: AppConstants.userTypeParticulier,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'authentification: $e');
    }
  }
}