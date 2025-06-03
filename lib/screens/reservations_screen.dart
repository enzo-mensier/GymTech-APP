import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/reservation.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_data_table.dart';
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

  // Formater la date au format JJ/MM
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '--/--';
    try {
      final date = DateTime.tryParse(dateString);
      if (date != null) {
        return DateFormat('dd/MM').format(date);
      }
      return '--/--';
    } catch (e) {
      return '--/--';
    }
  }

  // Formater l'heure au format HH:MM
  String _formatHeure(String? heure) {
    if (heure == null) return '--:--';
    try {
      final parts = heure.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return heure;
    } catch (e) {
      return heure;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Réservations',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        CustomDataTable(
                          width: MediaQuery.of(context).size.width * 0.95,
                          margin: const EdgeInsets.only(bottom: 20),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'DATE',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'CRÉNEAU',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'ACTION',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          rows: reservations.map((reservation) {
                                        // Récupérer les informations du créneau
                                        final creneau = reservation.creneau;
                                        final heureDebut = _formatHeure(creneau?.heureDebut);
                                        final heureFin = _formatHeure(creneau?.heureFin);

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
                                                    _formatDate(reservation.dateReservation.toIso8601String()),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            // Colonne Créneau
                                            DataCell(
                                              Center(
                                                child: creneau != null
                                                    ? Container(
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
                                                          textAlign: TextAlign.center,
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
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
                                                          'Créneau #${reservation.idCreneau}',
                                                          style: const TextStyle(
                                                            fontStyle: FontStyle.italic,
                                                            color: Colors.grey,
                                                            fontSize: 14,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            
                                            // Colonne Action
                                            DataCell(
                                              Center(
                                                child: SizedBox(
                                                  width: 120,
                                                  child: ElevatedButton(
                                                    onPressed: () => _annulerReservation(reservation.id, context),
                                                    style: ElevatedButton.styleFrom(
                                                      elevation: 0,
                                                      backgroundColor: AppColors.negativeColor.withOpacity(0.1),
                                                      foregroundColor: AppColors.negativeColor,
                                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                        side: BorderSide(
                                                          color: AppColors.negativeColor,
                                                          width: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Annuler',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
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
                      ],
                    ),
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
