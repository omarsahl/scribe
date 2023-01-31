import 'package:injectable/injectable.dart';

class Env {
  Env._();

  static const development = 'development';
  static const production = 'production';
  static const unitTesting = 'unitTesting';
  static const instrumentationTesting = 'instrumentationTesting';
}

const development = Environment(Env.development);
const production = Environment(Env.production);
const unitTesting = Environment(Env.unitTesting);
const instrumentationTesting = Environment(Env.instrumentationTesting);
