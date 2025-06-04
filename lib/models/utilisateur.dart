class Utilisateur {
  final int? id;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? motDePasse;
  final String? genre;
  final String? dateNaissance;
  final String? token;

  Utilisateur({
    this.id,
    this.nom,
    this.prenom,
    this.email,
    this.motDePasse,
    this.genre,
    this.dateNaissance,
    this.token,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id_utilisateur'] != null ? int.tryParse(json['id_utilisateur'].toString()) : null,
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      motDePasse: json['mot_de_passe'],
      genre: json['genre'],
      dateNaissance: json['date_naissance'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_utilisateur': id,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        if (motDePasse != null) 'mot_de_passe': motDePasse,
        'genre': genre,
        'date_naissance': dateNaissance,
        if (token != null) 'token': token,
      };

  Utilisateur copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? motDePasse,
    String? genre,
    String? dateNaissance,
    String? token,
  }) {
    return Utilisateur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      motDePasse: motDePasse ?? this.motDePasse,
      genre: genre ?? this.genre,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      token: token ?? this.token,
    );
  }

  // Méthode utilitaire pour créer un Utilisateur à partir d'un UserModel
  factory Utilisateur.fromUserModel(UserModel model) {
    return Utilisateur(
      id: model.id != null ? int.tryParse(model.id!) : null,
      nom: model.nom,
      prenom: model.prenom,
      email: model.email,
      token: model.token,
    );
  }
}

// Ancienne classe UserModel maintenue pour la rétrocompatibilité
@Deprecated('Utilisez la classe Utilisateur à la place')
class UserModel {
  final String? id;
  final String? email;
  final String? prenom;
  final String? nom;
  final String? token;

  UserModel({
    this.id,
    this.email,
    this.prenom,
    this.nom,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      email: json['email'],
      prenom: json['prenom'],
      nom: json['nom'],
      token: json['token'],
    );
  }
}