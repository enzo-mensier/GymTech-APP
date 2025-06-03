import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import 'calendrier_screen.dart';
import 'utilisateurs_screen.dart';
import 'login_screen.dart';
import 'reservations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _userEmail; // Stocke l'email de l'utilisateur

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');

      if (email == null || email.isEmpty) {
        throw Exception('Aucun email trouvé');
      }

      setState(() {
        _userEmail = email;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement de l\'email')),
        );
      }
    }
  }

  Widget _buildPage(int index) {
    final apiService = const ApiService();

    switch (index) {
      case 0:
        return CalendrierScreen(apiService: apiService);
      case 1:
        return ReservationsScreen();
      case 2:
        return const UtilisateursScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _logout() async {
    try {
      // Utiliser le UserService pour gérer la déconnexion
      final userService = UserService();
      await userService.logout();

      if (!mounted) return;

      // Rediriger vers l'écran de connexion
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false, // Supprime toutes les routes de la pile
      );
    } catch (e) {
      if (!mounted) return;

      // Afficher un message d'erreur en cas de problème
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion: $e'),
          backgroundColor: AppColors.negativeColor,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) { // Index pour le bouton de déconnexion (maintenant à l'index 3)
      _showLogoutConfirmation();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _showLogoutConfirmation() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8.0,
          title: Text(
            'Déconnexion',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.contrastColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Annuler',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.negativeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 2,
              ),
              child: Text(
                'Se déconnecter',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        showUserInfo: true,
        prenom: _userEmail,
      ),
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.backgroundColor,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.navColor,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          elevation: 10,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Créneaux'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Mes Réservations'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Utilisateurs'),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Déconnexion'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
    );
  }
}