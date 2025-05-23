import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importez le package
import '../widgets/custom_button.dart';
import 'login_screen.dart'; // Importez l'écran de connexion

class ParametresScreen extends StatelessWidget {
  const ParametresScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprimez le token d'authentification
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Redirigez vers l'écran de connexion
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Paramètres'),
          SizedBox(height: 20),
          CustomButton(
            text: 'Déconnexion',
            onPressed: () => _logout(context), // Appelez la fonction de déconnexion
          ),
        ],
      ),
    );
  }
}