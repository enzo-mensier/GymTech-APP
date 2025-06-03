import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/creneau.dart';
import '../widgets/custom_button.dart';
import 'dart:async';

class CalendrierScreen extends StatefulWidget {
  final ApiService _apiService;

  const CalendrierScreen({
    super.key,
    ApiService? apiService,
  }) : _apiService = apiService ?? const ApiService();

  @override
  State<CalendrierScreen> createState() => _CalendrierScreenState();
}

class _CalendrierScreenState extends State<CalendrierScreen> {
  late Future<List<Creneau>> _futureCreneaux;
  ApiService get _apiService => widget._apiService;

  @override
  void initState() {
    super.initState();
    _futureCreneaux = _refreshCreneaux();
  }

  // Méthode pour rafraîchir les créneaux
  Future<List<Creneau>> _refreshCreneaux() async {
    try {
      return await _apiService.getCreneaux();
    } catch (e) {
      throw Exception('Erreur lors du chargement des créneaux: $e');
    }
  }

  // Méthode pour gérer la réservation d'un créneau
  Future<void> _reserverCreneau(int creneauId, BuildContext context) async {
    try {
      // Récupérer l'ID de l'utilisateur connecté depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');

      if (userId == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté pour réserver un créneau')),
        );
        return;
      }

      // Afficher un indicateur de chargement
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        // Effectuer la réservation
        await _apiService.createReservation(userId, creneauId);

        // Mettre à jour la disponibilité du créneau
        await _apiService.updateCreneauDisponibilite(creneauId, false);

        // Fermer le dialogue de chargement
        if (!context.mounted) return;
        Navigator.of(context).pop();

        // Afficher un message de succès
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Créneau réservé avec succès'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Rafraîchir la liste des créneaux
        if (context.mounted) {
          setState(() {
            _futureCreneaux = _refreshCreneaux();
          });
        }
      } catch (e) {
        // Fermer le dialogue de chargement en cas d'erreur
        if (context.mounted) {
          Navigator.of(context).pop();

          String errorMessage = 'Une erreur est survenue';

          if (e.toString().contains('404')) {
            errorMessage = 'Créneau non trouvé';
          } else if (e.toString().contains('401') || e.toString().contains('403')) {
            errorMessage = 'Session expirée. Veuillez vous reconnecter';
          } else if (e.toString().contains('timeout')) {
            errorMessage = 'Le serveur met trop de temps à répondre';
          } else if (e.toString().contains('déjà réservé')) {
            errorMessage = 'Ce créneau est déjà réservé';
          } else {
            errorMessage = 'Erreur: ${e.toString().split(':').last.trim()}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $errorMessage'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Planning des créneaux',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _futureCreneaux = _refreshCreneaux();
                  });
                  await _futureCreneaux;
                },
                child: FutureBuilder<List<Creneau>>(
                  future: _futureCreneaux,
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
                                  child: Text('Disponibilité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Text(
                                        creneau.estDisponible ? 'Disponible' : 'Complet',
                                        style: TextStyle(
                                          color: creneau.estDisponible ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      child: SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: CustomButton(
                                          text: creneau.estDisponible ? 'Réserver' : 'Complet',
                                          onPressed: creneau.estDisponible
                                              ? () => _reserverCreneau(creneau.id, context)
                                              : null,
                                        ),
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
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}