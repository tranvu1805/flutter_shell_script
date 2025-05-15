import 'package:dartz/dartz.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Login extends UseCase<User, LoginEvent> {
  final AuthRepository repository;

  Login(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginEvent params) async {
    return await repository.login(params.email, params.password);
  }
}
