import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'calendrier_screen.dart';
import 'casiers_screen.dart';
import 'login_screen.dart';
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
    switch (index) {
      case 0:
        return CalendrierScreen();
      case 1:
        return CasiersScreen();
      case 2:
        return UtilisateursScreen();
      case 3:
        return ParametresScreen();
      default:
        return Container();
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/images/gymtech_logo.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
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