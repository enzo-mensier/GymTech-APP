import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/casier.dart';

class CasiersScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  CasiersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Casier>>(
      future: apiService.getCasiers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Casier casier = snapshot.data![index];
              return ListTile(
                title: Text('Casier ${casier.numeroCasier}'),
                subtitle: Text('Vestiaire ${casier.idVestiaire}'),
                trailing: casier.idUtilisateur == null
                    ? ElevatedButton(
                  onPressed: () {
                    // TODO: Gérer l'attribution
                  },
                  child: Text('Attribuer'),
                )
                    : Text('Attribué'),
              );
            },
          );
        } else {
          return Center(child: Text('Aucun casier trouvé'));
        }
      },
    );
  }
}