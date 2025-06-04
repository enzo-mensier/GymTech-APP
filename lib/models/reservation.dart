import 'creneau.dart';

class Reservation {
  final int id;
  final int idUtilisateur;
  final int idCreneau;
  final DateTime dateReservation;
  final Creneau? creneau;
  
  // Valeurs par défaut
  static const int defaultId = 0;
  static const int defaultIdUtilisateur = 0;
  static const int defaultIdCreneau = 0;
  static final DateTime defaultDateReservation = DateTime.now();

  const Reservation({
    required this.id,
    required this.idUtilisateur,
    required this.idCreneau,
    required this.dateReservation,
    this.creneau,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    try {
      // Vérifier si json est null
      if (json.isEmpty) {
        return Reservation.createDefault();
      }

      // Créer un objet Creneau à partir des données du créneau si elles existent
      Creneau? creneau;
      if (json['creneau'] != null && json['creneau'] is Map<String, dynamic>) {
        try {
          creneau = Creneau(
            id: (json['id_creneau'] ?? json['creneau']['id_creneau'] ?? 0) as int,
            date: (json['creneau']['date_creneau']?.toString() ?? '') as String,
            heureDebut: (json['creneau']['heure_debut']?.toString() ?? '') as String,
            heureFin: (json['creneau']['heure_fin']?.toString() ?? '') as String,
            disponibilite: (json['creneau']['disponibilite'] is bool)
                ? json['creneau']['disponibilite'] as bool
                : (json['creneau']['disponibilite'] == 1 || 
                   json['creneau']['disponibilite'] == '1' || 
                   json['creneau']['disponibilite'] == true),
          );
          
          // Debug: Vérifier la conversion de la disponibilité
          print('Conversion de la disponibilité pour le créneau ${creneau.id}: ' 
              '${json['creneau']['disponibilite']} -> ${creneau.disponibilite}');
        } catch (e) {
          print('Erreur lors de la création du créneau: $e');
        }
      }
      
      // Gérer la date de réservation
      DateTime dateReservation;
      try {
        if (json['date_reservation'] != null) {
          dateReservation = DateTime.tryParse(json['date_reservation'].toString()) ?? DateTime.now();
        } else {
          dateReservation = DateTime.now();
        }
      } catch (e) {
        print('Erreur lors du parsing de la date: $e');
        dateReservation = DateTime.now();
      }
      
      return Reservation(
        id: (json['id_reservation'] ?? 0) as int,
        idUtilisateur: (json['id_utilisateur'] ?? 0) as int,
        idCreneau: (json['id_creneau'] ?? 0) as int,
        dateReservation: dateReservation,
        creneau: creneau,
      );
    } catch (e) {
      print('Erreur lors de la création de la réservation: $e');
      print('JSON reçu: $json');
      return Reservation.createDefault();
    }
  }

  // Créer une réservation par défaut
  factory Reservation.createDefault() {
    return Reservation(
      id: defaultId,
      idUtilisateur: defaultIdUtilisateur,
      idCreneau: defaultIdCreneau,
      dateReservation: DateTime.now(),
    );
  }

  // Convertir en Map pour la sérialisation
  Map<String, dynamic> toJson() => {
    'id_reservation': id,
    'id_utilisateur': idUtilisateur,
    'id_creneau': idCreneau,
    'date_reservation': dateReservation.toIso8601String(),
    if (creneau != null) 'creneau': creneau!.toJson(),
  };
  
  // Créer une copie de la réservation avec des valeurs mises à jour
  Reservation copyWith({
    int? id,
    int? idUtilisateur,
    int? idCreneau,
    DateTime? dateReservation,
    Creneau? creneau,
  }) {
    return Reservation(
      id: id ?? this.id,
      idUtilisateur: idUtilisateur ?? this.idUtilisateur,
      idCreneau: idCreneau ?? this.idCreneau,
      dateReservation: dateReservation ?? this.dateReservation,
      creneau: creneau ?? this.creneau,
    );
  }
  
  @override
  String toString() {
    return 'Reservation(id: $id, idUtilisateur: $idUtilisateur, idCreneau: $idCreneau, dateReservation: $dateReservation, creneau: $creneau)';
  }
}
