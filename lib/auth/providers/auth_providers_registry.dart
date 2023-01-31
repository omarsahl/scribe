import 'package:injectable/injectable.dart';
import 'package:kanban/auth/models/auth_params.dart';
import 'package:kanban/auth/providers/auth_provider.dart';

@singleton
class KAuthProvidersRegistry {
  final Set<KAuthProvider> _providers = {};

  List<KAuthProvider> get allProviders => List.unmodifiable(_providers);

  KAuthProvider getProvider(AuthProviderParams params) {
    try {
      return _providers.firstWhere((provider) => provider.accepts(params));
    } catch (e) {
      throw StateError('No provider found that supports auth parameters: $params');
    }
  }

  void register(KAuthProvider provider) {
    if (_providers.contains(provider)) {
      return;
    }
    _providers.add(provider);
  }
}
