class Creneau {
  final int id;
  final String date;
  final String heureDebut;
  final String heureFin;
  final bool disponibilite;
  
  // Getter pour une meilleure lisibilité
  bool get estDisponible => disponibilite;

  Creneau({
    required this.id,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.disponibilite,
  });

  factory Creneau.fromJson(Map<String, dynamic> json) {
    try {
      if (json.isEmpty) {
        return Creneau(
          id: 0,
          date: '',
          heureDebut: '',
          heureFin: '',
          disponibilite: false,
        );
      }

      return Creneau(
        id: (json['id_creneau'] ?? 0) as int,
        date: (json['date_creneau']?.toString() ?? '') as String,
        heureDebut: (json['heure_debut']?.toString() ?? '') as String,
        heureFin: (json['heure_fin']?.toString() ?? '') as String,
        disponibilite: (json['disponibilite'] is bool) 
            ? json['disponibilite'] as bool 
            : (json['disponibilite'] == 1 || json['disponibilite'] == '1' || json['disponibilite'] == true),
      );
    } catch (e) {
      print('Erreur lors de la création du créneau: $e');
      print('JSON reçu: $json');
      return Creneau(
        id: 0,
        date: '',
        heureDebut: '',
        heureFin: '',
        disponibilite: false,
      );
    }
  }

  // Convertir l'objet en Map pour la sérialisation
  Map<String, dynamic> toJson() => {
    'id_creneau': id,
    'date_creneau': date,
    'heure_debut': heureDebut,
    'heure_fin': heureFin,
    'disponibilite': disponibilite ? 1 : 0,
  };
}