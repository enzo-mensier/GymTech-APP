import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/creneau.dart';
import '../widgets/custom_button.dart';
import 'package:intl/intl.dart';

class CalendrierScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  CalendrierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Creneau>>(
      future: apiService.getCreneaux(),
      builder: (context, snapshot) {
        // Si les données sont en cours de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Si une erreur est survenue
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        // Si les données sont chargées
        if (snapshot.hasData && snapshot.data != null) {
          final creneaux = snapshot.data!;
          
          // Si la liste des créneaux est vide
          if (creneaux.isEmpty) {
            return const Center(child: Text('Aucun créneau trouvé'));
          }
          
          // Afficher le tableau des créneaux
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.92,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 40,
                  horizontalMargin: 20,
                  headingRowHeight: 50,
                  dataRowHeight: 60,
                  columns: const [
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Début', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Fin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                  rows: creneaux.map((creneau) {
                    // Formater la date au format JJ/MM
                    String formattedDate = '';
                    try {
                      final date = DateTime.parse(creneau.date);
                      formattedDate = DateFormat('dd/MM').format(date);
                    } catch (e) {
                      formattedDate = creneau.date;
                    }
                    
                    // Formater les heures au format HH:MM
                    String formatHeure(String heure) {
                      try {
                        final time = TimeOfDay(
                          hour: int.parse(heure.split(':')[0]),
                          minute: int.parse(heure.split(':')[1]),
                        );
                        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      } catch (e) {
                        return heure;
                      }
                    }
                    
                    final heureDebut = formatHeure(creneau.heureDebut);
                    final heureFin = formatHeure(creneau.heureFin);
                    
                    return DataRow(
                      cells: [
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(formattedDate, style: const TextStyle(fontSize: 15)),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(heureDebut, style: const TextStyle(fontSize: 15)),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(heureFin, style: const TextStyle(fontSize: 15)),
                          ),
                        ),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: creneau.disponibilite
                                ? CustomButton(
                                    text: 'Réserver',
                                    onPressed: () {
                                      // TODO: Gérer la réservation
                                    },
                                  )
                                : CustomButton.secondary(
                                    text: 'Réservé',
                                    onPressed: () {
                                      // Aucune action pour les créneaux déjà réservés
                                    },
                                  ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }
        
        // Par défaut, afficher un message d'erreur générique
        return const Center(child: Text('Une erreur inattendue est survenue'));
      },
    );
  }
}