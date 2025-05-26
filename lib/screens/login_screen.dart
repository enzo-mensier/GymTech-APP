import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiantController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authService = AuthService();
        final response = await authService.login(
          _identifiantController.text,
          _passwordController.text,
        );

        // Stocker le token d'authentification
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        
        try {
          // Récupérer les informations complètes de l'utilisateur
          final userData = await authService.getUserProfile();
          print('Données utilisateur reçues: $userData');
          
          // Sauvegarder les informations utilisateur
          await prefs.setString('email', _identifiantController.text);
          await prefs.setString('prenom', userData['prenom']?.toString() ?? '');
          await prefs.setString('nom', userData['nom']?.toString() ?? '');
          await prefs.setString('genre', userData['genre']?.toString() ?? '');
          await prefs.setString('dateNaissance', userData['date_naissance']?.toString() ?? '');
          await prefs.setString('dateInscription', userData['date_inscription']?.toString() ?? '');
          
          print('Informations utilisateur sauvegardées avec succès');
        } catch (e) {
          print('Erreur lors de la récupération du profil utilisateur: $e');
          // Sauvegarder au moins l'email en cas d'erreur
          await prefs.setString('email', _identifiantController.text);
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur de connexion: ${e.toString()}',
              style: AppTextStyles.regular.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.negativeColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40.0),
                // Logo au milieu de la page
                Center(
                  child: Image.asset(
                    'assets/images/gymtech_logo.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24.0),
                // Titre de la page
                Text(
                  'Connexion',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32.0),

                // Champ Identifiant
                TextFormField(
                  controller: _identifiantController,
                  style: TextStyle(color: AppColors.textColor), // Texte en noir
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: AppTextStyles.regular.copyWith(color: AppColors.textColor),
                    prefixIcon: Icon(Icons.email, color: AppColors.contrastColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.contrastColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.contrastColor),
                    ),
                    floatingLabelStyle: AppTextStyles.regular.copyWith(color: AppColors.contrastColor),
                    hintStyle: TextStyle(color: AppColors.textColor),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre identifiant';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleLogin(), // Déclencher _handleLogin
                ),
                SizedBox(height: 15),

                // Champ Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: TextStyle(color: AppColors.textColor), // Texte en noir
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: AppTextStyles.regular.copyWith(color: AppColors.textColor),
                    prefixIcon: Icon(Icons.lock, color: AppColors.contrastColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.contrastColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.contrastColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.contrastColor),
                    ),
                    floatingLabelStyle: AppTextStyles.regular.copyWith(color: AppColors.contrastColor),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleLogin(), // Déclencher _handleLogin
                ),
                SizedBox(height: 24),

                // Bouton de connexion
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'SE CONNECTER',
                    style: AppTextStyles.bold.copyWith(
                      color: AppColors.backgroundColor,
                      fontSize: 17,
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Lien vers la page d'inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas encore de compte ? ',
                      style: AppTextStyles.regular.copyWith(color: AppColors.textColor),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                      child: Text(
                        'S\'inscrire',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifiantController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
