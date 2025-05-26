import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/utilisateur.dart';
import '../models/casier.dart';
import '../models/creneau.dart';

class ApiService {
  final String baseUrl = 'https://gymtech-api.onrender.com'; // serveur eb ligne
  //final String baseUrl = 'http://192.168.1.11:3002/api'; // Remplacez par votre adresse IP

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
}