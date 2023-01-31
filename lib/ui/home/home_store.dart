import 'package:injectable/injectable.dart';
import 'package:kanban/auth/auth_manager.dart';
import 'package:kanban/data/entity/board_entity.dart';
import 'package:kanban/data/entity/user_entity.dart';
import 'package:kanban/data/kanban_repository.dart';
import 'package:kanban/di/scopes/home_screen_scope.dart';
import 'package:mobx/mobx.dart';

part 'home_store.g.dart';

@singleton
@homeScreenScope
class HomeStore = _HomeStore with _$HomeStore;

abstract class _HomeStore with Store {
  _HomeStore(this._repo, this._authManager);

  final KRepository _repo;
  final AuthManager _authManager;

  late ObservableStream<KUser?> currentUser = ObservableStream(_authManager.watchCurrentUser);

  late ObservableStream<List<KBoard>> allBoards = ObservableStream(_repo.getAllBoards());
}
