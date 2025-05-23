import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/utilisateur.dart';

class UtilisateursScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  UtilisateursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Utilisateur>>(
      future: apiService.getUtilisateurs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Utilisateur utilisateur = snapshot.data![index];
              return ListTile(
                title: Text('${utilisateur.prenom} ${utilisateur.nom}'),
                subtitle: Text(utilisateur.email),
              );
            },
          );
        } else {
          return Center(child: Text('Aucun utilisateur trouvé'));
        }
      },
    );
  }
}