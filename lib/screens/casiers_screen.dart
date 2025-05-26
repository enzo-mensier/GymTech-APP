import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/casier.dart';

class CasiersScreen extends StatelessWidget {
  final ApiService _apiService;

  // Constructeur par défaut
  const CasiersScreen({
    super.key, 
    ApiService? apiService,
  }) : _apiService = apiService ?? const ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Casiers',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Casier>>(
                future: _apiService.getCasiers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Center(child: Text('Aucun casier trouvé'));
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final casier = snapshot.data![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              'Casier ${casier.numeroCasier}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Vestiaire ${casier.idVestiaire}'),
                            trailing: casier.idUtilisateur == null
                                ? ElevatedButton(
                                    onPressed: () {
                                      // TODO: Gérer l'attribution
                                    },
                                    child: const Text('Attribuer'),
                                  )
                                : const Text(
                                    'Attribué',
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('Aucune donnée disponible'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}