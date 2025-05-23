class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String motDePasse;
  final String genre;
  final String dateNaissance;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
    required this.genre,
    required this.dateNaissance,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id_utilisateur'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      motDePasse: json['mot_de_passe'],
      genre: json['genre'],
      dateNaissance: json['date_naissance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_utilisateur': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'mot_de_passe': motDePasse,
      'genre': genre,
      'date_naissance': dateNaissance,
    };
  }
}