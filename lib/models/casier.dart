class Casier {
  final int id;
  final int numeroCasier;
  final int idVestiaire;
  final int? idUtilisateur; // Peut être null

  Casier({
    required this.id,
    required this.numeroCasier,
    required this.idVestiaire,
    this.idUtilisateur,
  });

  factory Casier.fromJson(Map<String, dynamic> json) {
    return Casier(
      id: json['id_casier'],
      numeroCasier: json['numero_casier'],
      idVestiaire: json['id_vestiaire'],
      idUtilisateur: json['id_utilisateur'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_casier': id,
      'numero_casier': numeroCasier,
      'id_vestiaire': idVestiaire,
      'id_utilisateur': idUtilisateur,
    };
  }
}