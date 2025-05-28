import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../services/api_service.dart';
import 'calendrier_screen.dart';
import 'casiers_screen.dart';
import 'utilisateurs_screen.dart';
import 'parametres_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _buildPage(int index) {
    // Créer une seule instance de ApiService pour toute l'application
    final apiService = const ApiService();
    
    switch (index) {
      case 0:
        return CalendrierScreen(apiService: apiService);
      case 1:
        return CasiersScreen(apiService: apiService);
      case 2:
        return const UtilisateursScreen();
      case 3:
        return const ParametresScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        showUserInfo: true,
      ),
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundColor,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.navColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 10,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Réservation'),
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Vestiaires'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Utilisateur'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Déconnexion'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}