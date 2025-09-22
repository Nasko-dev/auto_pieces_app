import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../particulier/home_page.dart';

// Page qui utilise exactement le même système que les particuliers pour créer une demande
// mais avec le contexte vendeur (menu vendeur, etc.)
class SellerCreateRequestPage extends ConsumerWidget {
  const SellerCreateRequestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On réutilise exactement la même page que les particuliers
    // Le flag isSellerRequest sera géré automatiquement via l'authentification
    return const HomePage();
  }
}