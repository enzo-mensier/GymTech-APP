import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'dart:io';

class AuthService {
  final String baseUrl = 'https://gymtech-api.onrender.com'; // serveur eb ligne
  //final String baseUrl = 'http://192.168.1.11:3002/api'; // Remplacez par votre adresse IP
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/login');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final Map<String, dynamic> body = {
        'email': email,
        'password': password,
      };

      print('\n🔵 ===== DÉBUT TENTATIVE DE CONNEXION =====');
      print('🌐 URL: $url');
      print('📤 En-têtes de la requête:');
      headers.forEach((key, value) => print('   $key: $value'));
      print('📦 Corps de la requête: ${jsonEncode(body)}');
      
      final startTime = DateTime.now();
      print('⏳ Envoi de la requête...');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(Duration(seconds: 15));

      final duration = DateTime.now().difference(startTime);
      print('✅ Réponse reçue en ${duration.inMilliseconds}ms');
      print('📊 Statut HTTP: ${response.statusCode}');
      
      // Vérifier le Content-Type de la réponse
      final contentType = response.headers['content-type'] ?? '';
      print('📋 Content-Type de la réponse: $contentType');
      
      if (!contentType.toLowerCase().contains('application/json')) {
        throw FormatException('Le serveur n\'a pas renvoyé une réponse JSON valide. Content-Type: $contentType');
      }

      // Afficher le corps de la réponse avec formatage
      print('📥 Corps de la réponse (${response.body.length} caractères):');
      print('--- DÉBUT RÉPONSE ---');
      print(response.body);
      print('--- FIN RÉPONSE ---');

      // Tenter de décoder la réponse JSON
      print('🔍 Tentative de décodage JSON...');
      final dynamic responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData is! Map<String, dynamic>) {
          throw FormatException('La réponse JSON doit être un objet (Map)');
        }
        
        print('✅ Décodage JSON réussi');
        print('📦 Données décodées:');
        responseData.forEach((key, value) {
          print('   $key: ${key.toLowerCase().contains('token') ? '***TOKEN_MASQUÉ***' : value}');
        });
        
        return responseData as Map<String, dynamic>;
      } else {
        // Gestion des erreurs avec réponse JSON
        final errorMessage = (responseData is Map && responseData['message'] != null)
            ? responseData['message'].toString()
            : 'Erreur inconnue';
        print('❌ Erreur de connexion: ${response.statusCode} - $errorMessage');
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      print('❌ Erreur de connexion au serveur: $e');
      throw Exception('Impossible de se connecter au serveur. Vérifiez votre connexion Internet.');
    } on FormatException catch (e) {
      print('❌ Format de réponse invalide: $e');
      throw Exception('Erreur de format de données reçues du serveur');
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Non authentifié');
      }
      
      final url = Uri.parse('$baseUrl/api/auth/me');
      print('🔵 Récupération du profil utilisateur...');
      print('🌐 URL: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('📊 Statut HTTP: ${response.statusCode}');
      print('📦 Réponse: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Profil utilisateur récupéré avec succès');
        return responseData as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body);
        final errorMsg = error['message'] ?? 'Erreur inconnue';
        print('❌ Erreur lors de la récupération du profil: $errorMsg');
        throw Exception(errorMsg);
      }
    } on FormatException catch (e) {
      print('❌ Erreur de format de réponse: $e');
      throw Exception('Format de réponse invalide du serveur');
    } catch (e) {
      print('❌ Erreur lors de la récupération du profil: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String genre,
    required String dateNaissance,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/register');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final body = {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
        'genre': genre,
        'date_naissance': dateNaissance,
      };

      print('🔵 ===== DÉBUT TENTATIVE D\'INSCRIPTION =====');
      print('🌐 URL: $url');
      print('📤 En-têtes de la requête:');
      headers.forEach((key, value) => print('   $key: $value'));
      print('📦 Corps de la requête: ${jsonEncode(body)}');
      
      final startTime = DateTime.now();
      print('⏳ Envoi de la requête...');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(Duration(seconds: 15));

      final duration = DateTime.now().difference(startTime);
      print('✅ Réponse reçue en ${duration.inMilliseconds}ms');
      print('📊 Statut HTTP: ${response.statusCode}');
      
      // Vérifier le Content-Type de la réponse
      final contentType = response.headers['content-type'] ?? '';
      print('📋 Content-Type de la réponse: $contentType');
      
      // Afficher le corps de la réponse avec formatage
      print('📥 Corps de la réponse (${response.body.length} caractères):');
      print('--- DÉBUT RÉPONSE ---');
      print(response.body);
      print('--- FIN RÉPONSE ---');

      // Tenter de décoder la réponse JSON
      print('🔍 Tentative de décodage JSON...');
      
      try {
        final dynamic responseData = jsonDecode(response.body);
        
        if (response.statusCode == 201) {
          if (responseData is! Map<String, dynamic>) {
            throw FormatException('La réponse JSON doit être un objet (Map)');
          }
          
          print('✅ Inscription réussie');
          print('📦 Données décodées:');
          responseData.forEach((key, value) {
            print('   $key: ${key.toLowerCase().contains('token') ? '***TOKEN_MASQUÉ***' : value}');
          });
          
          return responseData as Map<String, dynamic>;
        } else {
          // Gestion des erreurs avec réponse JSON
          final errorMessage = (responseData is Map && responseData['message'] != null)
              ? responseData['message'].toString()
              : 'Erreur inconnue';
          print('❌ Erreur d\'inscription: ${response.statusCode} - $errorMessage');
          throw Exception(errorMessage);
        }
      } on FormatException catch (e) {
        print('❌ Format de réponse invalide: $e');
        throw Exception('Erreur de format de données reçues du serveur');
      }
    } on http.ClientException catch (e) {
      print('❌ Erreur de connexion au serveur: $e');
      throw Exception('Impossible de se connecter au serveur. Vérifiez votre connexion Internet.');
    } on FormatException catch (e) {
      print('❌ Format de réponse invalide: $e');
      throw Exception('Erreur de format de données reçues du serveur');
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      rethrow;
    }
  }
}
