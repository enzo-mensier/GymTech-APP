  import 'dart:convert';
import 'dart:convert' show utf8;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/reservation.dart';
import 'api_service.dart';

class ReservationService {
  final ApiService _apiService;
  final String _basePath = 'reservations';
  String _token = ''; // Le token sera récupéré dynamiquement

  ReservationService({required ApiService apiService}) 
    : _apiService = apiService;

  // Méthode pour mettre à jour le token
  void setToken(String token) {
    _token = token;
  }

  // Récupérer toutes les réservations de l'utilisateur connecté
  Future<List<Reservation>> getMesReservations() async {
    print('[ReservationService] Début de getMesReservations');
    try {
      print('[ReservationService] Récupération des préférences partagées...');
      final prefs = await SharedPreferences.getInstance();
      print('[ReservationService] Préférences partagées chargées');
      
      // Afficher toutes les clés pour le débogage
      final keys = prefs.getKeys();
      print('[ReservationService] Clés dans SharedPreferences: $keys');
      
      // Afficher la valeur de chaque clé
      for (var key in keys) {
        print('[ReservationService] $key: ${prefs.get(key)}');
      }
      
      final userId = prefs.getInt('id');
      print('[ReservationService] ID utilisateur récupéré: $userId');
      
      if (userId == null) {
        print('[ReservationService] ERREUR: Aucun ID utilisateur trouvé dans SharedPreferences');
        throw Exception('Utilisateur non connecté');
      }
      
      // Essayer différents formats d'URL pour la compatibilité
      final url = '${_apiService.baseUrl}/api/reservations?utilisateurId=$userId';
      print('[ReservationService] URL de l\'API: $url');
      
      print('[ReservationService] Envoi de la requête GET à: $url');
      // Récupérer le token depuis les préférences déjà chargées
      final token = prefs.getString('auth_token') ?? '';
      _token = token; // Mettre à jour le token
      
      print('[ReservationService] Token d\'authentification: ${token.isNotEmpty ? 'présent' : 'manquant\''}');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('[ReservationService] Timeout de la requête');
          throw Exception('La requête a expiré');
        },
      );
      
      print('[ReservationService] Réponse reçue - Status: ${response.statusCode}');
      print('[ReservationService] En-têtes de la réponse: ${response.headers}');
      print('[ReservationService] Corps de la réponse (brut): ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
          print('[ReservationService] Réservations décodées: ${jsonResponse.length}');
          return jsonResponse.map((json) => Reservation.fromJson(json)).toList();
        } catch (e) {
          print('[ReservationService] Erreur lors du décodage JSON: $e');
          rethrow;
        }
      } else {
        final errorMsg = 'Erreur HTTP ${response.statusCode}: ${response.body}';
        print('[ReservationService] $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      final errorMsg = 'Erreur lors de la récupération des réservations: $e';
      print('[ReservationService] $errorMsg');
      throw Exception(errorMsg);
    }
  }

  // Annuler une réservation
  Future<void> annulerReservation(int reservationId) async {
    try {
      final url = '${_apiService.baseUrl}/api/reservations/$reservationId';
      print('[ReservationService] URL d\'annulation: $url');
      
      print('[ReservationService] Envoi de la requête DELETE à: $url');
      print('[ReservationService] Token d\'authentification: ${_token.isNotEmpty ? 'présent' : 'manquant\''}');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      
      print('[ReservationService] Réponse d\'annulation - Status: ${response.statusCode}');
      print('[ReservationService] Corps de la réponse d\'annulation: ${response.body}');
      
      if (response.statusCode != 200) {
        final errorMsg = 'Erreur lors de l\'annulation de la réservation: ${response.statusCode}';
        print('[ReservationService] $errorMsg - ${response.body}');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('[ReservationService] Erreur lors de l\'annulation de la réservation: $e');
      rethrow;
    }
  }
}
