import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;

  const User({required this.id, required this.email});

  const User.empty()
      : this(
          email: "_empty.email",
          id: "_empty_id",
        );

  @override
  List<Object?> get props => [id, email];
}
