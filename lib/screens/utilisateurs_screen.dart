import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../services/user_service.dart';
import '../widgets/custom_app_bar.dart';
import 'dart:developer' as developer;

class UtilisateursScreen extends StatefulWidget {
  const UtilisateursScreen({super.key});

  @override
  _UtilisateursScreenState createState() => _UtilisateursScreenState();
}

class _UtilisateursScreenState extends State<UtilisateursScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic> _userData = {};
  Map<String, dynamic>? _lockerData;
  bool _isLoading = true;
  bool _isLockerLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userService.getCurrentUser();
      print('Données utilisateur reçues dans _loadUserdata:');
      user.forEach((key, value) {
        print('$key: $value (${value.runtimeType})');
      });

      // Vérifier si les données de base sont présentes
      if (user['id_utilisateur'] == null) {
        throw Exception('Aucun ID utilisateur trouvé');
      }

      setState(() {
        _userData = user;
        _isLoading = false;
      });

      // Charger les informations du casier
      _loadLockerData(user['id_utilisateur']);
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement de votre profil';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLockerData(int userId) async {
    if (_isLockerLoading) return;

    setState(() {
      _isLockerLoading = true;
    });

    try {
      final lockerData = await _userService.getUserLocker(userId);
      setState(() {
        _lockerData = lockerData;
      });
    } catch (e) {
      print('Erreur lors du chargement du casier: $e');
      // Ne pas afficher d'erreur à l'utilisateur pour le casier
    } finally {
      setState(() {
        _isLockerLoading = false;
      });
    }
  }

  Widget _buildUserInfo() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);

    // Gestion des dates
    DateTime? dateNaissance;
    DateTime? dateInscription;

    try {
      dateNaissance = _userData['date_naissance'] != null && _userData['date_naissance'].isNotEmpty
          ? DateTime.tryParse(_userData['date_naissance'])
          : null;
      dateInscription = _userData['date_inscription'] != null && _userData['date_inscription'].isNotEmpty
          ? DateTime.tryParse(_userData['date_inscription'])
          : null;
    } catch (e) {
      developer.log('Erreur de parsing des dates: $e');
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // En-tête avec avatar, nom et email
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  // Avatar circulaire
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.primaryColor,
                        width: 2.0,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nom et prénom
                  Text(
                    '${_userData['prenom'] ?? ''} ${_userData['nom'] ?? ''}'.trim(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Email
                  if (_userData['email'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _userData['email'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Cartes empilées verticalement
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Première carte - Informations personnelles
                _buildSection(
                  title: 'Informations',
                  icon: Icons.person_outline,
                  children: [
                    _buildInfoRow(
                      label: 'Genre',
                      value: _userData['genre']?.toString() ?? 'Non spécifié',
                      icon: Icons.transgender,
                    ),
                    _buildInfoRow(
                      label: 'Date de naissance',
                      value: dateNaissance != null
                          ? dateFormat.format(dateNaissance)
                          : 'Non spécifiée',
                      icon: Icons.cake,
                    ),
                    _buildInfoRow(
                      label: 'Membre depuis',
                      value: dateInscription != null
                          ? 'Le ${dateFormat.format(dateInscription)}'
                          : 'Date inconnue',
                      icon: Icons.calendar_today,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Deuxième carte - Casier
                _buildSection(
                  title: 'Mon Casier',
                  icon: Icons.lock_outline,
                  children: [
                    _buildLockerInfo(),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête de la section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Contenu de la section
            ...children,
          ],
        ),
      ),
    );
  }


  Widget _buildLockerInfo() {
    if (_isLockerLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Chargement des informations du casier...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_lockerData == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucun casier ne vous est actuellement attribué.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_lockerData?['numero_casier'] != null && _lockerData!['numero_casier'] != 'Inconnu')
            _buildInfoRow(
              label: 'Numéro de casier',
              value: 'N°${_lockerData!['numero_casier']}',
              icon: Icons.lock,
              valueStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          if (_lockerData?['type_vestiaire'] != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              label: 'Vestiaire',
              value: _userData['genre']?.toString() ?? 'Non spécifié',
              icon: Icons.transgender,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
    TextStyle? valueStyle,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'Non spécifié',
                  style: valueStyle ?? theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      )
          : _buildUserInfo(),
    );
  }
}