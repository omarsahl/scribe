import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:kanban/core/io/file_utils.dart';
import 'package:path_provider/path_provider.dart';

@singleton
class PathProvider {
  PathProvider();

  Future<Directory> get tempFilesDir => getTemporaryDirectory();

  Future<Directory> get appFilesDir => getApplicationSupportDirectory();

  Future<Directory> get appDocsDir => getApplicationDocumentsDirectory();

  Future<Directory> get configDir async => _ensureSubDirCreated(await appFilesDir, 'kconfig');

  Future<Directory> _ensureSubDirCreated(Directory parent, String child) => parent.joinDirs(child).create();
}
