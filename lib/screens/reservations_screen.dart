import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/creneau_service.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final _creneauService = CreneauService();
  List<Map<String, dynamic>> _availableCreneaux = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableCreneaux();
  }

  Future<void> _loadAvailableCreneaux() async {
    try {
      final creneaux = await _creneauService.getAvailableCreneaux();
      setState(() {
        _availableCreneaux = creneaux;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du chargement des créneaux: ${e.toString()}',
            style: AppTextStyles.regular.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.negativeColor,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final date = DateFormat('dd/MM/yyyy').format(dateTime);
    final time = DateFormat('HH:mm').format(dateTime);
    return '$date à $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réservations'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _availableCreneaux.isEmpty
              ? Center(child: Text('Aucun créneau disponible'))
              : ListView.builder(
                  itemCount: _availableCreneaux.length,
                  itemBuilder: (context, index) {
                    final creneau = _availableCreneaux[index];
                    final date = DateTime.parse(creneau['date_creneau']);
                    final heureDebut = DateTime.parse(
                        '${creneau['date_creneau']}T${creneau['heure_debut']}');
                    final heureFin = DateTime.parse(
                        '${creneau['date_creneau']}T${creneau['heure_fin']}');

                    return Card(
                      child: ListTile(
                        title: Text('Créneau du ${_formatDateTime(date)}'),
                        subtitle: Text(
                          'De ${_formatDateTime(heureDebut)} à ${_formatDateTime(heureFin)}'
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
