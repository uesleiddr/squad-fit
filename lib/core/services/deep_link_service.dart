import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  // Callback para quando um código de convite é recebido
  void Function(String inviteCode)? onInviteCodeReceived;

  // Inicializa o serviço de deep links
  Future<void> init() async {
    // Verifica se o app foi aberto por um deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Erro ao obter link inicial: $e');
    }

    // Escuta por deep links enquanto o app está aberto
    _subscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) {
        debugPrint('Erro no stream de deep links: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link recebido: $uri');

    // Formato esperado: squadfit://join/CODIGO ou https://squadfit.app/join/CODIGO
    final pathSegments = uri.pathSegments;

    if (pathSegments.isNotEmpty && pathSegments.first == 'join') {
      if (pathSegments.length > 1) {
        final inviteCode = pathSegments[1].toUpperCase();
        debugPrint('Código de convite extraído: $inviteCode');
        onInviteCodeReceived?.call(inviteCode);
      }
    }
  }

  // Gera o link de convite para compartilhar
  String generateInviteLink(String inviteCode) {
    // Por enquanto usa o scheme personalizado
    // Quando tiver domínio configurado, usar https://seudominio.com/join/CODIGO
    return 'squadfit://join/$inviteCode';
  }

  void dispose() {
    _subscription?.cancel();
  }
}
