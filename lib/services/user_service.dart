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
        print('📦 Réponse brute: ${response.body}');

        if (response.statusCode == 200) {
          final dynamic responseData = jsonDecode(response.body);
          print('Réponse API /api/auth/me:');
          print('Type de responseData: ${responseData.runtimeType}');
          
          if (responseData is Map) {
            print('Clés de responseData: ${responseData.keys.join(', ')}');
            if (responseData['data'] != null) {
              print('Type de data: ${responseData['data'].runtimeType}');
              if (responseData['data'] is Map) {
                print('Clés de data: ${(responseData['data'] as Map).keys.join(', ')}');
                if (responseData['data']['user'] != null) {
                  print('Type de user: ${responseData['data']['user'].runtimeType}');
                  if (responseData['data']['user'] is Map) {
                    print('Clés de user: ${(responseData['data']['user'] as Map).keys.join(', ')}');
                  }
                }
              }
            }
          }
          
          if (responseData is Map && responseData['data'] is Map && responseData['data']['user'] is Map) {
            final user = responseData['data']['user'] as Map<String, dynamic>;
            print('Données utilisateur:');
            user.forEach((key, value) {
              print('$key: $value (${value.runtimeType})');
            });
            
            // Mettre à jour les préférences partagées avec les nouvelles données
            await prefs.setInt('id', user['id'] ?? 0);
            await prefs.setString('nom', user['nom']?.toString() ?? '');
            await prefs.setString('prenom', user['prenom']?.toString() ?? '');
            await prefs.setString('genre', user['genre']?.toString() ?? 'Non spécifié');
            await prefs.setString('dateNaissance', user['date_naissance']?.toString() ?? '');
            await prefs.setString('dateInscription', user['date_inscription']?.toString() ?? '');
            
            // Mettre à jour l'objet utilisateur avec les nouvelles données
            userData.addAll({
              'id_utilisateur': user['id'],
              'nom': user['nom']?.toString() ?? '',
              'prenom': user['prenom']?.toString() ?? '',
              'email': user['email']?.toString() ?? '',
              'genre': user['genre']?.toString() ?? 'Non spécifié',
              'date_naissance': user['date_naissance']?.toString(),
              'date_inscription': user['date_inscription']?.toString(),
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

  // Récupérer les informations du casier de l'utilisateur
  Future<Map<String, dynamic>?> getUserLocker(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Non authentifié');
      }
      
      final url = Uri.parse('$baseUrl/api/casiers/utilisateur/$userId');
      print('🔵 Récupération des informations du casier...');
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
        print('Réponse complète du casier:');
        print(responseData);
        
        if (responseData is Map && 
            responseData['data'] is Map && 
            responseData['data']['casier'] is Map) {
          final casier = responseData['data']['casier'] as Map<String, dynamic>;
          print('Données du casier:');
          print(casier);
          
          // Retourner les données du casier
          return {
            'numero_casier': casier['numero_casier']?.toString() ?? 'Inconnu',
            'id_vestiaire': casier['id_vestiaire']?.toString() ?? '',
            'type_vestiaire': casier['id_vestiaire'] == 1 ? 'Homme' : 'Femme'
          };
        }
        return null;
      } else if (response.statusCode == 404) {
        // Aucun casier trouvé pour cet utilisateur
        return null;
      } else {
        throw Exception('Erreur lors de la récupération du casier');
      }
    } catch (e) {
      print('Erreur lors de la récupération du casier: $e');
      rethrow;
    }
  }

  // Méthode pour déconnecter l'utilisateur
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Supprimer les données d'authentification
      await prefs.remove('auth_token');
      await prefs.remove('email');
      await prefs.remove('id');
      await prefs.remove('nom');
      await prefs.remove('prenom');
      await prefs.remove('genre');
      await prefs.remove('dateNaissance');
      await prefs.remove('dateInscription');
      
      print('✅ Utilisateur déconnecté avec succès');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }
}
