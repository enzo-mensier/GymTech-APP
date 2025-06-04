import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiantController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = AuthService();
      final response = await authService.login(
        _identifiantController.text,
        _passwordController.text,
      );

      // Stocker le token d'authentification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['data']['token']);
      
      try {
        // Récupérer les informations complètes de l'utilisateur
        final userData = await authService.getUserProfile();
        print('Données utilisateur reçues: $userData');
        
        // Vérifier que les données sont bien présentes
        if (userData['data']?['user'] != null) {
          final user = userData['data']['user'];
          
          // Sauvegarder les informations utilisateur
          await prefs.setString('email', _identifiantController.text);
          await prefs.setInt('id', user['id'] as int); // Sauvegarde de l'ID utilisateur
          await prefs.setString('prenom', user['prenom']?.toString() ?? '');
          await prefs.setString('nom', user['nom']?.toString() ?? '');
          await prefs.setString('genre', user['genre']?.toString() ?? '');
          await prefs.setString('dateNaissance', user['date_naissance']?.toString() ?? '');
          await prefs.setString('dateInscription', user['date_inscription']?.toString() ?? '');
          
          print('✅ Informations utilisateur sauvegardées avec succès');
          print('   - ID: ${user['id']}');
          print('   - Nom: ${user['nom']}');
          print('   - Prénom: ${user['prenom']}');
        } else {
          print('⚠️ Aucune donnée utilisateur trouvée dans la réponse');
          // Sauvegarder au moins l'email
          await prefs.setString('email', _identifiantController.text);
        }
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
      if (mounted) {
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                  style: TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: AppTextStyles.regular.copyWith(color: AppColors.textColor),
                    prefixIcon: Icon(Icons.email, color: AppColors.contrastColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.contrastColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.contrastColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.contrastColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.negativeColor),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.negativeColor, width: 2),
                    ),
                    errorStyle: AppTextStyles.regular.copyWith(
                      color: AppColors.negativeColor,
                      fontSize: 12,
                    ),
                    floatingLabelStyle: AppTextStyles.regular.copyWith(color: AppColors.contrastColor),
                    hintStyle: TextStyle(color: AppColors.textColor),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                  style: TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: AppTextStyles.regular.copyWith(color: AppColors.textColor),
                    prefixIcon: Icon(Icons.lock, color: AppColors.contrastColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.contrastColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.contrastColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.contrastColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.contrastColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.negativeColor),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.negativeColor, width: 2),
                    ),
                    errorStyle: AppTextStyles.regular.copyWith(
                      color: AppColors.negativeColor,
                      fontSize: 12,
                    ),
                    floatingLabelStyle: AppTextStyles.regular.copyWith(color: AppColors.contrastColor),
                    hintStyle: TextStyle(color: AppColors.textColor),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                _isLoading
                    ? CustomButton(
                        onPressed: null,
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : CustomButton(
                        text: 'SE CONNECTER',
                        onPressed: _handleLogin,
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
