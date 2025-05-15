import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required super.id, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }

  UserModel copyWith(
    String? id,
    String? email,
  ) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }

  const UserModel.empty() : this(email: "_empty.email", id: "_empty.id");
}
