import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/reservation.dart';
import '../widgets/custom_button.dart';
import '../utils/colors.dart';

class ReservationsScreen extends StatefulWidget {
  final ApiService _apiService;

  const ReservationsScreen({
    super.key,
    ApiService? apiService,
  }) : _apiService = apiService ?? const ApiService();

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  late Future<List<Reservation>> _futureReservations;
  ApiService get _apiService => widget._apiService;

  @override
  void initState() {
    super.initState();
    _futureReservations = _loadReservations();
  }

  Future<List<Reservation>> _loadReservations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id');
      
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      return await _apiService.getMesReservations(userId);
    } catch (e) {
      throw Exception('Erreur lors du chargement des réservations: $e');
    }
  }

  Future<void> _annulerReservation(int reservationId, BuildContext context) async {
    try {
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

      // Ici, vous devriez implémenter la logique pour annuler la réservation
      // Par exemple :
      // await _apiService.annulerReservation(reservationId);
      
      // Simuler un délai pour l'exemple
      await Future.delayed(const Duration(seconds: 1));

      // Fermer le dialogue de chargement
      if (!context.mounted) return;
      Navigator.of(context).pop();

      // Afficher un message de succès
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation annulée avec succès'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Rafraîchir la liste des réservations
      setState(() {
        _futureReservations = _loadReservations();
      });
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _futureReservations = _loadReservations();
            });
            await _futureReservations;
          },
          child: FutureBuilder<List<Reservation>>(
            future: _futureReservations,
            builder: (context, snapshot) {
              // Si les données sont en cours de chargement
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Si une erreur est survenue
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur lors du chargement des réservations',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _futureReservations = _loadReservations();
                            });
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Si les données sont chargées
              if (snapshot.hasData && snapshot.data != null) {
                final reservations = snapshot.data!;

                // Si l'utilisateur n'a pas de réservations
                if (reservations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune réservation trouvée',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Réservez un créneau pour commencer',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }


                // Afficher le tableau des réservations
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    columnSpacing: 16,
                    horizontalMargin: 8,
                    headingRowHeight: 50,
                    dataRowHeight: 70,
                    columns: const [
                      DataColumn(
                        label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Créneau', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Heure', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows: reservations.map((reservation) {
                      // Formater la date au format JJ/MM/YYYY
                      String formatDate(String? dateString) {
                        if (dateString == null || dateString.isEmpty) return 'Date inconnue';
                        try {
                          final date = DateTime.tryParse(dateString);
                          if (date != null) {
                            return DateFormat('dd/MM/yyyy').format(date);
                          }
                          return dateString; // Retourne la chaîne originale si le parsing échoue
                        } catch (e) {
                          return 'Date invalide';
                        }
                      }

                      
                      // Formater l'heure au format HH:MM
                      String formatHeure(String? heure) {
                        if (heure == null) return '--:--';
                        try {
                          // Si l'heure est au format HH:MM:SS, on ne garde que HH:MM
                          final parts = heure.split(':');
                          if (parts.length >= 2) {
                            return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
                          }
                          return heure;
                        } catch (e) {
                          return heure;
                        }
                      }
                      
                      // Récupérer les informations du créneau
                      final creneau = reservation.creneau;
                      final dateCreneau = creneau?.date != null 
                          ? formatDate(creneau!.date)
                          : 'Date inconnue';
                          
                      final heureDebut = formatHeure(creneau?.heureDebut);
                      final heureFin = formatHeure(creneau?.heureFin);

                      // Afficher les informations de la réservation
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              formatDate(reservation.dateReservation.toIso8601String()),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (creneau != null) ...[
                                  Text(
                                    '$heureDebut - $heureFin',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateCreneau,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ] else
                                  Text(
                                    'Créneau #${reservation.idCreneau}',
                                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              creneau != null 
                                  ? '$heureDebut - $heureFin' 
                                  : 'Détails indisponibles',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () => _annulerReservation(reservation.id, context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                ),
                                child: const Text('Annuler'),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }

              // Par défaut, afficher un message d'erreur
              return const Center(
                child: Text('Aucune donnée disponible'),
              );
            },
          ),
        ),
      ),
    );
  }
}
