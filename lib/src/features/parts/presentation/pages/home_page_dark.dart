import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/car_parts_list.dart';

class HomePageDark extends StatefulWidget {
  const HomePageDark({super.key});

  @override
  State<HomePageDark> createState() => _HomePageDarkState();
}

class _HomePageDarkState extends State<HomePageDark> {
  // Couleurs inspirées de l'image
  static const Color _darkBg = Color(0xFF0A1A1A);
  static const Color _cardBg = Color(0xFF1C2C2C);
  static const Color _accent = Color(0xFF00D2AA);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFF8E9BA8);

  String _selectedType = 'engine';
  bool _isManualMode = false;
  bool _showDescription = false;

  final _plate = TextEditingController();
  final _partController = TextEditingController();
  final _marqueController = TextEditingController();
  final _modeleController = TextEditingController();
  final _anneeController = TextEditingController();
  final _motorisationController = TextEditingController();
  final _focusNode = FocusNode();
  
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  List<String> _selectedParts = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _partController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _plate.dispose();
    _partController.dispose();
    _marqueController.dispose();
    _modeleController.dispose();
    _anneeController.dispose();
    _motorisationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header simple
              _buildSimpleHeader(),
              
              const SizedBox(height: 32),
              
              // Titre principal
              Text(
                'Rechercher une pièce',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Trouvez la pièce qu\'il vous faut rapidement',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: _textSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Types de pièces
              _buildPartTypes(),
              
              const SizedBox(height: 24),
              
              // Identification véhicule
              _buildVehicleIdentification(),
              
              const SizedBox(height: 24),
              
              // Section pièces recherchées si véhicule identifié
              if (_canContinue()) _buildPartSearch(),
              
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSimpleHeader() {
    return Row(
      children: [
        Text(
          '9:41',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.notifications_none, 
            color: _textPrimary, size: 20),
        ),
      ],
    );
  }

  Widget _buildPartTypes() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedType = 'engine'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedType == 'engine' ? _accent.withOpacity(0.2) : _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: _selectedType == 'engine' 
                  ? Border.all(color: _accent, width: 2) 
                  : null,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.settings,
                    color: _selectedType == 'engine' ? _accent : _textSecondary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Moteur',
                    style: GoogleFonts.inter(
                      color: _selectedType == 'engine' ? _accent : _textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedType = 'body'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedType == 'body' ? _accent.withOpacity(0.2) : _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: _selectedType == 'body' 
                  ? Border.all(color: _accent, width: 2) 
                  : null,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.directions_car,
                    color: _selectedType == 'body' ? _accent : _textSecondary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Carrosserie',
                    style: GoogleFonts.inter(
                      color: _selectedType == 'body' ? _accent : _textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleIdentification() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Identification du véhicule',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (!_isManualMode) ...[
            // Plaque d'immatriculation
            Container(
              decoration: BoxDecoration(
                color: _darkBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _plate.text.isNotEmpty ? _accent : Colors.grey.shade800,
                ),
              ),
              child: TextFormField(
                controller: _plate,
                style: GoogleFonts.inter(color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ex: AA-123-BB',
                  hintStyle: GoogleFonts.inter(color: _textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: _plate.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.check, color: _accent),
                        onPressed: () => setState(() {}),
                      )
                    : null,
                ),
                onChanged: (v) => setState(() {}),
              ),
            ),
            
            const SizedBox(height: 12),
            
            TextButton(
              onPressed: () => setState(() => _isManualMode = true),
              child: Text(
                'Saisie manuelle',
                style: GoogleFonts.inter(color: _accent),
              ),
            ),
          ] else ...[
            // Mode manuel
            TextButton.icon(
              onPressed: () => setState(() => _isManualMode = false),
              icon: Icon(Icons.arrow_back, color: _accent, size: 16),
              label: Text('Retour plaque', style: GoogleFonts.inter(color: _accent)),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildManualField('Marque', _marqueController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildManualField('Modèle', _modeleController),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildManualField('Année', _anneeController, TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildManualField('Motorisation', _motorisationController),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualField(String label, TextEditingController controller, [TextInputType? keyboardType]) {
    return Container(
      decoration: BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(color: _textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: _textSecondary, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
        onChanged: (v) => setState(() {}),
      ),
    );
  }

  Widget _buildPartSearch() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: _accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Véhicule identifié',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Quelle pièce recherchez-vous ?',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              color: _darkBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: _partController,
              focusNode: _focusNode,
              style: GoogleFonts.inter(color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Ex: phare, moteur, pare-choc...',
                hintStyle: GoogleFonts.inter(color: _textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          if (_selectedParts.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedParts.map((part) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accent),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(part, style: GoogleFonts.inter(color: _accent)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => _selectedParts.remove(part)),
                      child: Icon(Icons.close, color: _accent, size: 16),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit() ? _submitRequest : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Poster ma demande',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOldHeader() {
    return Row(
      children: [
        // Avatar utilisateur
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [_accent, _accent.withOpacity(0.6)],
            ),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
        
        const SizedBox(width: 16),
        
        // Salutation et stats
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '9:41',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              Text(
                'Dernière visite il y a 3 heures',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Notifications
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(Icons.notifications_outlined, 
                  color: _textPrimary, size: 20),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSearchCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.search, color: _accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recherche Rapide',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      'Trouvez vos pièces en quelques secondes',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward, 
                  color: Colors.black, size: 18),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Champ de recherche principal
          Container(
            decoration: BoxDecoration(
              color: _darkBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _plate.text.isNotEmpty ? _accent : Colors.transparent,
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _plate,
              style: GoogleFonts.inter(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'AA-123-BB ou recherche libre...',
                hintStyle: GoogleFonts.inter(
                  color: _textSecondary,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: _plate.text.isNotEmpty 
                  ? IconButton(
                      icon: Icon(Icons.clear, color: _textSecondary),
                      onPressed: () => setState(() => _plate.clear()),
                    )
                  : null,
              ),
              onChanged: (v) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Mes Véhicules',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(
                'Voir tout',
                style: GoogleFonts.inter(
                  color: _accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Cartes de véhicules
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildVehicleCard(
                'Renault Clio',
                'AB-123-CD',
                'assets/images/car1.png',
                true,
              ),
              _buildVehicleCard(
                'Peugeot 308',
                'EF-456-GH',
                'assets/images/car2.png',
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(String name, String plate, String image, bool isSelected) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? Border.all(color: _accent, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? _accent.withOpacity(0.2) : _darkBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plate,
                  style: GoogleFonts.inter(
                    color: isSelected ? _accent : _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (isSelected)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.black),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _darkBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.build, color: _accent, size: 16),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _darkBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.history, color: _textSecondary, size: 16),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _darkBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.settings, color: _textSecondary, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularPartsGrid() {
    final parts = [
      {'title': 'Moteur', 'count': '2', 'icon': Icons.settings, 'color': _accent},
      {'title': 'Éclairage', 'count': '4', 'icon': Icons.lightbulb_outline, 'color': Colors.orange},
      {'title': 'Freinage', 'count': '2', 'icon': Icons.disc_full, 'color': Colors.red},
      {'title': 'Climatisation', 'count': '3', 'icon': Icons.ac_unit, 'color': Colors.blue},
      {'title': 'Échappement', 'count': '2', 'icon': Icons.directions_car, 'color': Colors.purple},
      {'title': 'Purificateur d\'air', 'count': '1', 'icon': Icons.air, 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pièces Populaires',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: parts.length,
          itemBuilder: (context, index) {
            final part = parts[index];
            return _buildPartCard(part);
          },
        ),
      ],
    );
  }

  Widget _buildPartCard(Map<String, dynamic> part) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                part['count'],
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              Text(
                'PIÈCES',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (part['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  part['icon'],
                  color: part['color'],
                  size: 16,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            part['title'],
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          
          const Spacer(),
          
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: part['color'],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: _darkBg,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Demandes Récentes',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _canSubmit() ? _submitRequest : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
            icon: const Icon(Icons.send, size: 18),
            label: Text(
              'Poster ma demande',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 90,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 0, '/home'),
          _buildNavItem(Icons.apps, 1, '/requests'),
          // Centre avec bouton spécial
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accent, _accent.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add, color: Colors.black, size: 28),
          ),
          _buildNavItem(Icons.favorite_border, 2, '/conversations'),
          _buildNavItem(Icons.settings, 3, '/become-seller'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String route) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        // Navigation
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? _accent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: isSelected ? _accent : _textSecondary,
          size: 22,
        ),
      ),
    );
  }

  // Methods utilitaires
  bool _canContinue() => _plate.text.isNotEmpty;
  bool _canSubmit() => _selectedParts.isNotEmpty || _partController.text.isNotEmpty;

  void _onTextChanged() {
    final query = _partController.text;
    setState(() {
      _suggestions = CarPartsList.searchParts(query);
      _showSuggestions = _suggestions.isNotEmpty && _focusNode.hasFocus;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _suggestions.isNotEmpty && _focusNode.hasFocus;
    });
  }

  void _submitRequest() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Demande postée avec succès!'),
        backgroundColor: _accent,
      ),
    );
  }
}