import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/competition_model.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/snackbar_helper.dart';

/// Modal V2 para convidar amigos para um desafio
class InviteFriendsModalV2 extends StatelessWidget {
  final CompetitionModel competition;
  final int memberCount;

  const InviteFriendsModalV2({
    super.key,
    required this.competition,
    this.memberCount = 1,
  });

  /// Mostra o modal
  static Future<void> show(
    BuildContext context, {
    required CompetitionModel competition,
    int memberCount = 1,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InviteFriendsModalV2(
        competition: competition,
        memberCount: memberCount,
      ),
    );
  }

  void _copyCode(BuildContext context) {
    final code = competition.inviteCode;
    Clipboard.setData(ClipboardData(text: code));
    SnackBarHelper.showSuccess(context, 'Código copiado!');
  }

  void _shareVia(BuildContext context, String platform) {
    SnackBarHelper.showInfo(context, 'Compartilhar via $platform em desenvolvimento');
  }

  @override
  Widget build(BuildContext context) {
    final code = competition.inviteCode;
    const maxMembers = 20;
    final slotsRemaining = maxMembers - memberCount;
    final systemNavPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.borderDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + systemNavPadding),
            child: Column(
              children: [
                // Header
                _buildHeader(memberCount, slotsRemaining),
                const SizedBox(height: 16),

                // QR Code
                _buildQrCode(code),
                const SizedBox(height: 16),

                // Code copy row
                _buildCodeCopyRow(context, code),
                const SizedBox(height: 14),

                // Share options
                _buildShareOptions(context),
                const SizedBox(height: 16),

                // Expiry note
                _buildExpiryNote(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int memberCount, int slotsRemaining) {
    return Column(
      children: [
        Text(
          'CONVIDAR AMIGOS',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          competition.name,
          style: TextStyle(
            fontFamily: AppTypography.fontDisplay,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group,
              size: 14,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(width: 5),
            Text(
              '$memberCount membros · $slotsRemaining vagas restantes',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQrCode(String code) {
    return Container(
      width: 200,
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _QrCodePainter(code: code),
      ),
    );
  }

  Widget _buildCodeCopyRow(BuildContext context, String code) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: AppShadows.insetHighlight,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CÓDIGO DO DESAFIO',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: AppColors.textTertiaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  code.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _copyCode(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  ...AppShadows.glowOrange,
                  ...AppShadows.insetHighlight,
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.content_copy,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Copiar',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOptions(BuildContext context) {
    final options = [
      _ShareOption(
        name: 'WhatsApp',
        icon: Icons.chat,
        color: const Color(0xFF22C55E),
      ),
      _ShareOption(
        name: 'Instagram',
        icon: Icons.photo_camera,
        color: const Color(0xFFFF3B8B),
      ),
      _ShareOption(
        name: 'Link',
        icon: Icons.link,
        color: AppColors.secondary,
      ),
      _ShareOption(
        name: 'Mais',
        icon: Icons.more_horiz,
        color: AppColors.textSecondaryDark,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMPARTILHAR VIA',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: options.map((option) {
            return Expanded(
              child: GestureDetector(
                onTap: () => _shareVia(context, option.name),
                child: Container(
                  margin: EdgeInsets.only(
                    right: option != options.last ? 10 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderDark),
                    boxShadow: AppShadows.insetHighlight,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: option.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          option.icon,
                          size: 20,
                          color: option.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        option.name,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHighContrast,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpiryNote() {
    return Text(
      'O código expira em 24h. Você pode gerar um novo a qualquer momento.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiaryDark,
        height: 1.5,
      ),
    );
  }
}

class _ShareOption {
  final String name;
  final IconData icon;
  final Color color;

  const _ShareOption({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Painter simples para QR code placeholder
class _QrCodePainter extends CustomPainter {
  final String code;

  _QrCodePainter({required this.code});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0B0D12);
    final cellSize = size.width / 21;

    // Pseudo-random pattern baseado no código
    for (int y = 0; y < 21; y++) {
      for (int x = 0; x < 21; x++) {
        final v = (x * 7 + y * 13 + y * x) ^ code.codeUnitAt((x + y) % code.length);
        if (v % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }

    // Corner markers
    _drawCornerMarker(canvas, 0, 0, cellSize);
    _drawCornerMarker(canvas, size.width - 7 * cellSize, 0, cellSize);
    _drawCornerMarker(canvas, 0, size.height - 7 * cellSize, cellSize);

    // Center logo
    final logoRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 5 * cellSize,
      height: 5 * cellSize,
    );
    canvas.drawRect(logoRect, Paint()..color = Colors.white);

    final innerLogoRect = logoRect.deflate(cellSize / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerLogoRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFFA8038),
    );

    // SF text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SF',
        style: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2,
      ),
    );
  }

  void _drawCornerMarker(Canvas canvas, double x, double y, double cellSize) {
    final paint = Paint()..color = const Color(0xFF0B0D12);
    final whitePaint = Paint()..color = Colors.white;

    // Outer
    canvas.drawRect(
      Rect.fromLTWH(x, y, 7 * cellSize, 7 * cellSize),
      paint,
    );
    // Middle white
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize, y + cellSize, 5 * cellSize, 5 * cellSize),
      whitePaint,
    );
    // Inner
    canvas.drawRect(
      Rect.fromLTWH(x + 2 * cellSize, y + 2 * cellSize, 3 * cellSize, 3 * cellSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
