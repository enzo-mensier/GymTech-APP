class Creneau {
  final int id;
  final String date;
  final String heureDebut;
  final String heureFin;
  final bool disponibilite;

  Creneau({
    required this.id,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.disponibilite,
  });

  factory Creneau.fromJson(Map<String, dynamic> json) {
    return Creneau(
      id: json['id_creneau'],
      date: json['date_creneau'] ?? '', // Valeur par défaut si null
      heureDebut: json['heure_debut'] ?? '', // Valeur par défaut si null
      heureFin: json['heure_fin'] ?? '', // Valeur par défaut si null
      disponibilite: json['disponibilite'] == 1,
    );
  }
}