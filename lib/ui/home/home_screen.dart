import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/data/entity/board_entity.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/di/scopes/home_screen_scope.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/style/shapes.dart';
import 'package:kanban/ui/dialogs/board/create_board_dialog.dart';
import 'package:kanban/ui/dialogs/dialog_utils.dart';
import 'package:kanban/ui/home/home_store.dart';
import 'package:kanban/ui/settings/settings_bottom_sheet.dart';
import 'package:kanban/ui/widgets/board_item_widget.dart';
import 'package:kanban/ui/widgets/empty_list_widget.dart';
import 'package:kanban/ui/widgets/error_view.dart';
import 'package:kanban/ui/widgets/progress.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/ui/widgets/user_avatar.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/mobx_ext.dart';

class HomeScreen extends StatefulObserverWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeStore _store;

  Widget get _userAvatar {
    final user = _store.currentUser.value;
    return UserAvatar(
      name: user?.name ?? '-',
      imageUrl: user?.photoUrl,
      onTap: _onTapAvatar,
    );
  }

  @override
  void initState() {
    super.initState();
    initHomeScreenScope();
    _store = getIt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onCreateNewBoard,
        icon: const Icon(Icons.add),
        shape: const StadiumBorder(),
        label: Text(context.localizations.createBoardButtonText),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 8,
      title: Text(
        context.localizations.appName,
        style: context.theme.textTheme.titleLarge?.copyWith(
          fontSize: 25,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        _userAvatar,
        const HSpace(10),
      ],
    );
  }

  Widget _buildContent() {
    return _store.allBoards.when(
      onData: (data) => _buildBoardsList(data),
      onError: (_) => const ErrorView(),
      onLoading: () => const DefaultProgressIndicator(centered: true),
    );
  }

  Widget _buildBoardsList(List<KBoard> boards) {
    if (boards.isEmpty) {
      return _emptyView();
    }
    return ListView.separated(
      itemCount: boards.length,
      padding: const EdgeInsets.symmetric(vertical: 15),
      itemBuilder: (context, index) {
        final board = boards[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: BoardItem(
            board: board,
            onTap: () => _onTapBoard(board),
          ),
        );
      },
      separatorBuilder: (context, _) {
        return const VSpace(15);
      },
    );
  }

  Widget _emptyView() {
    final localizations = context.localizations;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: EmptyListWidget(
          message: localizations.noBoardsMessage,
          actionWidget: FilledButton.icon(
            onPressed: _onCreateNewBoard,
            icon: const Icon(Icons.add),
            label: Text(localizations.createBoardButtonText),
          ),
        ),
      ),
    );
  }

  void _onTapAvatar() {
    showSettingsBottomSheet(context);
  }

  void _onCreateNewBoard() {
    newShowDialog(context, const CreateBoardWidget());
  }

  void _onTapBoard(KBoard board) {
    AppNavigator.push(context, const BoardScreenRoute(), args: board.id);
  }
}
