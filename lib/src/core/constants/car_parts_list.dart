class CarPartsList {
  // Liste des pièces automobiles courantes
  static const List<String> _allParts = [
    // Moteur
    'Pistons',
    'Cylindres',
    'Culasse',
    'Bloc moteur',
    'Vilebrequin',
    'Bielle',
    'Soupapes',
    'Arbre à cames',
    'Joint de culasse',
    'Pompe à eau',
    'Pompe à huile',
    'Thermostat',
    'Radiateur',
    'Ventilateur',
    'Courroie de distribution',
    'Courroie d\'accessoires',
    'Alternateur',
    'Démarreur',
    'Bougies d\'allumage',
    'Bobine d\'allumage',
    'Injecteurs',
    'Pompe à carburant',
    'Filtre à air',
    'Filtre à huile',
    'Filtre à carburant',
    'Turbo',
    'Collecteur d\'admission',
    'Collecteur d\'échappement',

    // Transmission
    'Boîte de vitesses',
    'Embrayage',
    'Disque d\'embrayage',
    'Plateau de pression',
    'Butée d\'embrayage',
    'Volant moteur',
    'Transmission',
    'Différentiel',
    'Cardans',
    'Soufflets de cardan',

    // Suspension
    'Amortisseurs',
    'Ressorts',
    'Coupelles d\'amortisseur',
    'Barre stabilisatrice',
    'Silentblocs',
    'Rotules',
    'Triangle de suspension',
    'Biellette de barre stabilisatrice',

    // Direction
    'Crémaillère de direction',
    'Pompe de direction assistée',
    'Rotule de direction',
    'Biellette de direction',
    'Volant',
    'Colonne de direction',

    // Freinage
    'Plaquettes de frein',
    'Disques de frein',
    'Tambours de frein',
    'Mâchoires de frein',
    'Étriers de frein',
    'Maître cylindre',
    'Liquide de frein',
    'Flexible de frein',
    'Frein à main',

    // Carrosserie
    'Pare-chocs avant',
    'Pare-chocs arrière',
    'Aile avant droite',
    'Aile avant gauche',
    'Aile arrière droite',
    'Aile arrière gauche',
    'Portière avant droite',
    'Portière avant gauche',
    'Portière arrière droite',
    'Portière arrière gauche',
    'Capot',
    'Coffre',
    'Hayon',
    'Toit ouvrant',
    'Rétroviseurs',
    'Grille de calandre',
    'Becquet',
    'Pare-brise',
    'Lunette arrière',
    'Vitres latérales',

    // Intérieur
    'Sièges avant',
    'Sièges arrière',
    'Tableau de bord',
    'Console centrale',
    'Volant',
    'Levier de vitesse',
    'Frein à main',
    'Tapis de sol',
    'Garnitures de porte',
    'Ciel de toit',
    'Airbags',
    'Ceintures de sécurité',
    'Autoradio',
    'Climatisation',
    'Chauffage',

    // Électrique
    'Batterie',
    'Alternateur',
    'Démarreur',
    'Faisceau électrique',
    'Fusibles',
    'Relais',
    'Phares',
    'Feux arrière',
    'Clignotants',
    'Feux de position',
    'Éclairage intérieur',
    'Calculateur moteur',
    'Capteurs',

    // Pneumatiques et jantes
    'Pneus',
    'Jantes',
    'Enjoliveurs',
    'Valves',
    'Écrous de roue',
  ];

  /// Recherche des pièces correspondant à la requête
  static List<String> searchParts(String query) {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    return _allParts
        .where((part) => part.toLowerCase().contains(queryLower))
        .take(10)
        .toList();
  }

  /// Obtient toutes les pièces disponibles
  static List<String> getAllParts() => List.from(_allParts);

  /// Obtient les pièces par catégorie
  static List<String> getPartsByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'moteur':
        return _allParts.take(28).toList();
      case 'transmission':
        return _allParts.skip(28).take(10).toList();
      case 'suspension':
        return _allParts.skip(38).take(8).toList();
      case 'direction':
        return _allParts.skip(46).take(6).toList();
      case 'freinage':
        return _allParts.skip(52).take(9).toList();
      case 'carrosserie':
        return _allParts.skip(61).take(22).toList();
      case 'interieur':
        return _allParts.skip(83).take(16).toList();
      case 'electrique':
        return _allParts.skip(99).take(14).toList();
      case 'pneumatiques':
        return _allParts.skip(113).take(5).toList();
      default:
        return [];
    }
  }
}
