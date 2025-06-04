import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/utilisateur.dart';
import '../models/casier.dart';
import '../models/creneau.dart';
import '../models/reservation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  const ApiService();
  static const String _baseUrl = 'https://gymtech-api.onrender.com'; // serveur en ligne
  //static const String _baseUrl = 'http://192.168.1.11:3002/api'; // Adresse IP locale

  String get baseUrl => _baseUrl;

  // Méthodes pour les utilisateurs
  Future<List<Utilisateur>> getUtilisateurs() async {
    final response = await http.get(Uri.parse('$baseUrl/api/utilisateurs'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((user) => Utilisateur.fromJson(user)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des utilisateurs');
    }
  }

  Future<Utilisateur> getUtilisateurById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/utilisateurs/$id'));

    if (response.statusCode == 200) {
      return Utilisateur.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de la récupération de l'utilisateur");
    }
  }

  Future<void> createUser(Utilisateur utilisateur) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/utilisateurs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(utilisateur.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la création de l\'utilisateur');
    }
  }

  Future<void> updateUser(Utilisateur utilisateur) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/utilisateurs/${utilisateur.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(utilisateur.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour de l\'utilisateur');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/utilisateurs/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur');
    }
  }

  // Méthodes pour les casiers
  Future<List<Casier>> getCasiers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/casiers'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((casier) => Casier.fromJson(casier)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des casiers');
    }
  }

  Future<Casier> getCasierById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/casiers/$id'));

    if (response.statusCode == 200) {
      return Casier.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération du casier');
    }
  }

  Future<void> updateCasier(Casier casier) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/casiers/${casier.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(casier.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour du casier');
    }
  }

  // Méthodes pour les créneaux
  Future<List<Creneau>> getCreneaux() async {
    final response = await http.get(Uri.parse('$baseUrl/api/creneaux'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((creneau) => Creneau.fromJson(creneau)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des créneaux');
    }
  }

  Future<Creneau> getCreneauById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/creneaux/$id'));

    if (response.statusCode == 200) {
      return Creneau.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération du créneau');
    }
  }

  Future<void> createReservation(int utilisateurId, int creneauId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/reservations'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id_utilisateur': utilisateurId,
        'id_creneau': creneauId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la création de la réservation');
    }
  }

  // Méthode pour mettre à jour la disponibilité d'un créneau
  Future<void> updateCreneauDisponibilite(int creneauId, bool disponible) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/creneaux/$creneauId/availability'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'disponibilite': disponible ? 1 : 0,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour de la disponibilité du créneau');
    }
  }

  // Récupérer les réservations d'un utilisateur
  Future<List<Reservation>> getMesReservations(int utilisateurId) async {
    try {
      print('🔵 Récupération des réservations pour l\'utilisateur ID: $utilisateurId');
      
      // Récupérer le token depuis les préférences partagées
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ Token d\'authentification manquant dans SharedPreferences');
        throw Exception('Token d\'authentification manquant');
      }
      
      print('🔑 Token récupéré avec succès');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservations/utilisateur/$utilisateurId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('📊 Statut de la réponse: ${response.statusCode}');
      print('📦 En-têtes de la réponse: ${response.headers}');
      print('📊 Statut de la réponse: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Si la réponse est une liste de créneaux (format actuel de l'API)
        if (jsonResponse is List) {
          print('ℹ️ Format de réponse détecté: Liste de créneaux');
          
          // Générer un ID unique pour chaque réservation (temporaire, à remplacer par un vrai ID si disponible)
          int tempId = 1;
          
          return jsonResponse.map<Reservation>((item) {
            try {
              print('📝 Traitement du créneau: $item');
              
              // Vérifier si c'est un créneau valide
              if (item is Map<String, dynamic> && item.containsKey('creneau')) {
                final creneau = item['creneau'];
                return Reservation(
                  id: tempId++, // ID temporaire
                  idUtilisateur: utilisateurId,
                  idCreneau: 0, // Non disponible dans la réponse actuelle
                  dateReservation: creneau['date_creneau'] != null 
                      ? DateTime.tryParse(creneau['date_creneau'].toString()) ?? DateTime.now()
                      : DateTime.now(),
                  creneau: Creneau(
                    id: 0, // Non disponible dans la réponse actuelle
                    date: creneau['date_creneau']?.toString() ?? '',
                    heureDebut: creneau['heure_debut']?.toString() ?? '',
                    heureFin: creneau['heure_fin']?.toString() ?? '',
                    disponibilite: false,
                  ),
                );
              } else {
                print('⚠️ Format de créneau invalide: $item');
                return Reservation.createDefault();
              }
            } catch (e) {
              print('❌ Erreur lors de la création de la réservation: $e');
              print('❌ Données problématiques: $item');
              return Reservation.createDefault();
            }
          }).where((r) => r.id != 0).toList();
        }
        // Si la réponse est un objet avec une clé 'data' qui contient la liste
        else if (jsonResponse is Map && jsonResponse['data'] is List) {
          print('ℹ️ Format de réponse détecté: Objet avec clé data');
          final reservationsData = jsonResponse['data'] as List;
          
          return reservationsData.map<Reservation>((item) {
            try {
              print('📝 Traitement de la réservation: $item');
              
              // Si le créneau est inclus dans la réponse
              if (item['creneau'] != null) {
                return Reservation(
                  id: item['id_reservation'] ?? 0,
                  idUtilisateur: item['id_utilisateur'] ?? 0,
                  idCreneau: item['id_creneau'] ?? 0,
                  dateReservation: item['date_reservation'] != null 
                      ? DateTime.tryParse(item['date_reservation'].toString()) ?? DateTime.now()
                      : DateTime.now(),
                  creneau: Creneau(
                    id: item['id_creneau'] ?? 0,
                    date: item['creneau']?['date_creneau']?.toString() ?? '',
                    heureDebut: item['creneau']?['heure_debut']?.toString() ?? '',
                    heureFin: item['creneau']?['heure_fin']?.toString() ?? '',
                    disponibilite: false,
                  ),
                );
              } else {
                // Si le créneau n'est pas inclus, on crée une réservation basique
                return Reservation(
                  id: item['id_reservation'] ?? 0,
                  idUtilisateur: item['id_utilisateur'] ?? 0,
                  idCreneau: item['id_creneau'] ?? 0,
                  dateReservation: item['date_reservation'] != null 
                      ? DateTime.tryParse(item['date_reservation'].toString()) ?? DateTime.now()
                      : DateTime.now(),
                );
              }
            } catch (e) {
              print('❌ Erreur lors de la création de la réservation: $e');
              print('❌ Données problématiques: $item');
              return Reservation.createDefault();
            }
          }).where((r) => r.id != 0).toList();
        } else {
          print('⚠️ Format de réponse inattendu: $jsonResponse');
          return [];
        }
      } else {
        print('❌ Erreur API: ${response.statusCode} - ${response.body}');
        throw Exception('Erreur lors de la récupération des réservations (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Erreur dans getMesReservations: $e');
      rethrow;
    }
  }
}