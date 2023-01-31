import 'dart:io';

import 'package:path/path.dart' as libpath;

extension DirManipulationExtension on Directory {
  /// Joins this directory's [path] with the given path parts using the current platform's [separator]
  ///
  /// ### Example
  /// ```
  /// final parentDir = Directory('foo'); // "foo/"
  /// final newDir = parentDir.joinDirs('bar', 'baz'); // "foo/bar/baz"
  /// ```
  Directory joinDirs(String? part1, [String? part2, String? part3, String? part4, String? part5]) {
    return Directory(libpath.join(path, part1, part2, part3, part4, part5));
  }

  /// Creates and returns a new file [name] inside of this [Directory].
  /// If [createIfNotExists] is true and the file doesn't exist, then it will be created.
  Future<File> createFile(String name, [bool createIfNotExist = false]) async {
    final file = File(libpath.join(path, name));
    if (createIfNotExist && !(await file.exists())) {
      return file.create();
    }
    return file;
  }
}
