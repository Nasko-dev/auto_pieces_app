import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/navigation/app_router.dart';
import 'src/core/constants/app_constants.dart';
import 'src/core/providers/particulier_auth_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 [Main] Démarrage de l\'app...');
  print('📡 [Main] URL Supabase: ${AppConstants.supabaseUrl}');
  print('🔑 [Main] Clé anon: ${AppConstants.supabaseAnonKey.substring(0, 20)}...');
  
  try {
    print('🔧 [Main] Initialisation de Supabase...');
    // Initialiser Supabase
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    print('✅ [Main] Supabase initialisé avec succès !');
    
    // Initialiser SharedPreferences
    print('💾 [Main] Initialisation de SharedPreferences...');
    final sharedPreferences = await SharedPreferences.getInstance();
    print('✅ [Main] SharedPreferences initialisé !');
    
    // Vérifier l'état de l'auth
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      print('👤 [Main] Utilisateur connecté: ${user.id}');
      print('📧 [Main] Email: ${user.email}');
    } else {
      print('👻 [Main] Aucun utilisateur connecté (mode anonyme)');
    }

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('❌ [Main] Erreur d\'initialisation: $e');
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Pièces d\'Occasion',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
