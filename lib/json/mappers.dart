@MappableLib(
  createCombinedContainer: true,
  discoveryMode: DiscoveryMode.package,
)
library mappers;

import 'package:dart_mappable/dart_mappable.dart';

const generateEncDecCpy = GenerateMethods.encode | GenerateMethods.decode | GenerateMethods.copy;
