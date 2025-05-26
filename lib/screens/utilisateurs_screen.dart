import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../services/user_service.dart';
import 'dart:developer' as developer;

class UtilisateursScreen extends StatefulWidget {
  const UtilisateursScreen({super.key});

  @override
  _UtilisateursScreenState createState() => _UtilisateursScreenState();
}

class _UtilisateursScreenState extends State<UtilisateursScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userService.getCurrentUser();
      print('Données utilisateur reçues dans _loadUserData:');
      user.forEach((key, value) {
        print('$key: $value (${value.runtimeType})');
      });
      setState(() {
        _userData = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement de votre profil';
        _isLoading = false;
      });
    }
  }

  Widget _buildUserInfo() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Gestion des dates
    DateTime? dateNaissance;
    DateTime? dateInscription;
    
    try {
      dateNaissance = _userData['date_naissance'] != null && _userData['date_naissance'].isNotEmpty
          ? DateTime.tryParse(_userData['date_naissance'])
          : null;
    } catch (e) {
      developer.log('Erreur de parsing des dates: $e');
    }
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryColor,
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Nom', _userData['nom']?.toString() ?? ''),
            const Divider(),
            _buildInfoRow('Prénom', _userData['prenom']?.toString() ?? ''),
            const Divider(),
            _buildInfoRow('Email', _userData['email']?.toString() ?? ''),
            const Divider(),
            _buildInfoRow('Genre', _userData['genre']?.toString() ?? 'Non spécifié'),
            const Divider(),
            _buildInfoRow(
              'Date de naissance', 
              dateNaissance != null ? dateFormat.format(dateNaissance) : 'Non spécifiée',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Non spécifié',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Mon Profil',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 50),
                              const SizedBox(height: 16),
                              Text(
                                _error,
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                                textAlign: TextAlign.center,
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
                    : Expanded(
                        child: SingleChildScrollView(
                          child: _buildUserInfo(),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}