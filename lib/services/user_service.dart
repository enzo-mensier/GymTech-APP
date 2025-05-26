import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String baseUrl = 'https://gymtech-api.onrender.com';

  // Récupérer les informations de l'utilisateur connecté
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final email = prefs.getString('email');
      
      if (token == null || email == null) {
        throw Exception('Non authentifié');
      }
      
      // Créer un objet utilisateur à partir des données stockées
      final userData = {
        'id_utilisateur': prefs.getInt('id'),
        'nom': prefs.getString('nom') ?? '',
        'prenom': prefs.getString('prenom') ?? '',
        'email': email,
        'genre': prefs.getString('genre') ?? 'Non spécifié',
        'date_naissance': prefs.getString('dateNaissance'),
        'date_inscription': prefs.getString('dateInscription'),
      };
      
      // Vérifier si on a toutes les informations nécessaires
      if (userData['id_utilisateur'] == null || 
          userData['nom'] == '' || 
          userData['prenom'] == '') {
        
        // Si des informations manquent, essayer de les récupérer depuis l'API
        final url = Uri.parse('$baseUrl/api/auth/me');
        print('🔵 Récupération des informations utilisateur...');
        print('🌐 URL: $url');
        
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('📊 Statut HTTP: ${response.statusCode}');
        print('📦 Réponse: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print('Réponse API /api/auth/me:');
          print(responseData);
          
          if (responseData is Map && responseData['user'] is Map) {
            final user = responseData['user'] as Map<String, dynamic>;
            print('Données utilisateur:');
            user.forEach((key, value) {
              print('$key: $value (${value.runtimeType})');
            });
            
            // Mettre à jour les préférences partagées avec les nouvelles données
            await prefs.setInt('id', user['id'] ?? 0);
            await prefs.setString('nom', user['nom'] ?? '');
            await prefs.setString('prenom', user['prenom'] ?? '');
            await prefs.setString('genre', user['genre'] ?? 'Non spécifié');
            await prefs.setString('dateNaissance', user['date_naissance'] ?? '');
            await prefs.setString('dateInscription', user['date_inscription'] ?? '');
            
            // Mettre à jour l'objet utilisateur avec les nouvelles données
            userData.addAll({
              'id_utilisateur': user['id'],
              'nom': user['nom'] ?? '',
              'prenom': user['prenom'] ?? '',
              'genre': user['genre'] ?? 'Non spécifié',
              'date_naissance': user['date_naissance'],
              'date_inscription': user['date_inscription'],
            });
          }
        } else {
          String errorMsg = 'Échec du chargement du profil';
          try {
            final dynamic error = jsonDecode(response.body);
            if (error is Map) {
              errorMsg = error['message']?.toString() ?? error.toString();
            } else {
              errorMsg = error?.toString() ?? errorMsg;
            }
          } catch (e) {
            errorMsg = 'Erreur inconnue: ${response.body}';
          }
          throw Exception(errorMsg);
        }
      }
      
      return userData;
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      rethrow;
    }
  }
}
