import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/creneau.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_data_table.dart';
import 'dart:async';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

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
      final token = prefs.getString('auth_token');

      if (userId == null || token == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour réserver un créneau'),
            backgroundColor: Colors.orange,
          ),
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
        // Vérifier d'abord si le créneau est toujours disponible
        final creneau = await _apiService.getCreneauById(creneauId);
        
        if (!creneau.estDisponible) {
          throw Exception('Ce créneau n\'est plus disponible');
        }

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
            content: Text('✅ Créneau réservé avec succès'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
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
          } else if (e.toString().contains('déjà réservé') || 
                    e.toString().contains('duplicate') ||
                    e.toString().contains('already exists')) {
            errorMessage = 'Vous avez déjà réservé ce créneau';
          } else if (e.toString().contains('plus disponible')) {
            errorMessage = 'Ce créneau n\'est plus disponible';
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
          
          // Rafraîchir la liste des créneaux en cas d'erreur
          if (context.mounted) {
            setState(() {
              _futureCreneaux = _refreshCreneaux();
            });
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur inattendue: ${e.toString().split(':').first}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
                'Créneaux',
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
                      child: CustomDataTable(
                        width: MediaQuery.of(context).size.width * 0.92,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        columnSpacing: 24,
                        horizontalMargin: 16,
                        headingRowHeight: 56,
                        dataRowHeight: 68,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'DATE',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'CRÉNEAU',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'ACTION',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ],
                        rows: creneaux.map((creneau) {
                          // Formater la date au format JJ/MM
                          String formattedDate = '';
                          try {
                            final date = DateTime.parse(creneau.date);
                            formattedDate = DateFormat('dd-MM').format(date);
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
                              // Colonne Date
                              DataCell(
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Colonne Créneau (Heure Début - Heure Fin)
                              DataCell(
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '$heureDebut - $heureFin',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Colonne Action
                              DataCell(
                                Center(
                                  child: SizedBox(
                                    width: 120,
                                    child: creneau.estDisponible
                                        ? CustomButton(
                                            text: 'Réserver',
                                            onPressed: () => _reserverCreneau(creneau.id, context),
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Complet',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
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