import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/models/user_model.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/auth/repositories/auth_remote_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewmodel extends _$AuthViewmodel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;
  late CurrentUserNotifier _currentUserNotifier;

  @override
  AsyncValue<UserModel>? build() { 
    // Build() function contains dependencies of a viewModel (here authviewmodel)
    // ref.watch() function helps to rebuild build() or simply
    // updates the same instance of authremoterepository whenever we make changes in it
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserNotifierProvider.notifier);
    return null;
  }

  Future<void> initSharedPreferences() async {
    await _authLocalRepository.init();
  }
//--------------------------Check for successful signup-------------------------------------//c
  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final response = await _authRemoteRepository.signup(name: name, email: email, password: password);

    // resolve LEFT and RIGHT values
    final val = switch (response) {
      Left(value: final l) => state = AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => state = AsyncValue.data(r),
    };
    print(val);
  }

//--------------------------Check for successful login and get Token-------------------------------------//c
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final response = await _authRemoteRepository.login(email: email, password: password);

    // resolve LEFT and RIGHT values
    final val = switch (response) {
      Left(value: final l) => state = AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => _loginSuccess(r),
    };
    print(val);
  }

  AsyncValue<UserModel>? _loginSuccess(UserModel user){
    _authLocalRepository.setToken(user.token);
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }

//--------------------------Get user Data from repository using token value-------------------------------------//c
  Future<UserModel?> getData() async {
    state = const AsyncValue.loading();
    final token = _authLocalRepository.getToken();
    if (token != null){
      // Send request to server to get User Data by token
      final response = await _authRemoteRepository.getCurrentUserData(token);
      final val = switch (response){
        Left(value: final l) => state = AsyncValue.error(l.message, StackTrace.current),
        Right(value: final r) => _getDataSuccess(r)
      };
      return val.value;
    }
    return null; // User has not logged in (user not exist)
  }

  AsyncValue<UserModel> _getDataSuccess(UserModel user){
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }
}


