import 'dart:convert';
import 'package:http/http.dart' as http;

class CreneauService {
  final String baseUrl = 'https://gymtech-api.onrender.com/api'; // serveur eb ligne
  //final String baseUrl = 'http://192.168.1.11:3002/api'; // Remplacez par votre adresse IP
  
  Future<List<Map<String, dynamic>>> getAvailableCreneaux() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/creneaux/available'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Erreur lors de la récupération des créneaux');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }
}
