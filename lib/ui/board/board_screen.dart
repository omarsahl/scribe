import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kanban/data/entity/board_entity.dart';
import 'package:kanban/di/di_config.dart';
import 'package:kanban/di/scopes/board_screen_scope.dart';
import 'package:kanban/nav/navigator.dart';
import 'package:kanban/ui/board/board_store.dart';
import 'package:kanban/ui/board/group_widget.dart';
import 'package:kanban/ui/dialogs/dialog_utils.dart';
import 'package:kanban/ui/dialogs/group/group_dialog.dart';
import 'package:kanban/ui/widgets/empty_list_widget.dart';
import 'package:kanban/ui/widgets/error_view.dart';
import 'package:kanban/ui/widgets/progress.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:kanban/utils/mobx_ext.dart';

class BoardScreen extends StatefulObserverWidget {
  const BoardScreen(this.boardId, {super.key});

  final String boardId;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late final BoardStore _store;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    initBoardScreenScope();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.85);
    _store = getIt();
    _store.init(widget.boardId);
  }

  @override
  void dispose() {
    removeBoardScreenScope();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Material(
      child: _store.boardDetailsStream.when(
        onError: (e) => const ErrorView(),
        onLoading: () => const DefaultProgressIndicator(centered: true),
        onData: (boardDetails) {
          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            appBar: _appBar(boardDetails.board),
            body: _content(boardDetails.board),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(KBoard board) {
    final theme = context.theme;
    final localizations = context.localizations;
    return AppBar(
      elevation: 4,
      titleSpacing: 0,
      automaticallyImplyLeading: true,
      title: Text(
        board.name,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _onCreateNewGroup,
          tooltip: context.localizations.createGroupButtonText,
          style: IconButton.styleFrom(foregroundColor: theme.colorScheme.primary),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_added),
          onPressed: _onTapHistory,
          tooltip: localizations.completedTasks,
          style: IconButton.styleFrom(foregroundColor: theme.colorScheme.primary),
        ),
      ],
    );
  }

  Widget _content(KBoard board) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            board.description,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: _buildGroups(),
        ),
      ],
    );
  }

  Widget _buildGroups() {
    final localizations = context.localizations;
    return _store.taskGroups.when(
      onLoading: () => const SizedBox(),
      onError: (e) => const ErrorView(),
      onData: (data) {
        if (data.isEmpty) {
          return EmptyListWidget(
            message: localizations.noGroupsMessage,
            actionWidget: FilledButton.icon(
              onPressed: _onCreateNewGroup,
              icon: const Icon(Icons.add),
              label: Text(localizations.createGroupButtonText),
            ),
          );
        }
        return PageView.builder(
          padEnds: false,
          pageSnapping: false,
          itemCount: data.length,
          controller: _pageController,
          itemBuilder: (context, index) {
            final group = data[index];
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 5, index == data.length - 1 ? 15 : 0, 0),
              child: GroupWidget(group.id, group.boardId),
            );
          },
        );
      },
    );
  }

  void _onCreateNewGroup() {
    newShowDialog(context, GroupActionsWidget.create(widget.boardId));
  }

  void _onTapHistory() {
    AppNavigator.push(context, const CompletedTasksScreenRoute(), args: widget.boardId);
  }
}
