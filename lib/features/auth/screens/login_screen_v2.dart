import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/service_locator.dart';
import '../services/auth_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../shared/widgets/v2/v2.dart';

class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({super.key});

  @override
  State<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends State<LoginScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = getIt<AuthService>();

  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await _authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await _authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.message);
      });
    } catch (e) {
      debugPrint('Auth Error: $e');
      setState(() {
        _errorMessage = 'Erro: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      setState(() {
        _errorMessage = 'Erro ao entrar com Google: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Digite seu email para recuperar a senha.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.resetPassword(email);
      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Email de recuperação enviado!');
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.message);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao enviar email. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email ou senha incorretos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Email não confirmado. Verifique sua caixa de entrada.';
    }
    if (message.contains('User already registered')) {
      return 'Este email já está em uso.';
    }
    if (message.contains('Password should be at least')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (message.contains('Invalid email')) {
      return 'Email inválido.';
    }
    if (message.contains('rate limit')) {
      return 'Muitas tentativas. Tente novamente mais tarde.';
    }
    return 'Ocorreu um erro. Tente novamente.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deep,
      body: Stack(
        children: [
          // Background with gradients - EXATO do design
          _buildBackground(),

          // Noise overlay texture
          _buildNoiseOverlay(),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // Logo - centered
                    Center(
                      child: SFLogo(width: 220),
                    ),
                    const SizedBox(height: 28),

                    // Tagline - EXATO do design
                    _buildTagline(),
                    const SizedBox(height: 28),

                    // Error message
                    if (_errorMessage != null) ...[
                      _buildErrorMessage(),
                      const SizedBox(height: 16),
                    ],

                    // Form fields
                    _buildEmailField(),
                    const SizedBox(height: 12),
                    _buildPasswordField(),

                    // Forgot password - só no login
                    if (_isLogin) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _isLoading ? null : _resetPassword,
                          child: Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Primary CTA button
                    SFButton(
                      variant: SFButtonVariant.primary,
                      size: SFButtonSize.lg,
                      fullWidth: true,
                      onPressed: _isLoading ? null : _submitForm,
                      isLoading: _isLoading,
                      iconRight: Icons.arrow_forward,
                      child: Text(_isLogin ? 'Entrar no squad' : 'Criar conta'),
                    ),
                    const SizedBox(height: 20),

                    // Divider com "ou"
                    _buildDivider(),
                    const SizedBox(height: 20),

                    // Google button
                    SFButton(
                      variant: SFButtonVariant.secondary,
                      size: SFButtonSize.lg,
                      fullWidth: true,
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGoogleIcon(),
                          const SizedBox(width: 12),
                          const Text('Continuar com Google'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Toggle login/signup - bottom
                    _buildToggleMode(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Background com gradientes radiais - EXATO do design original
  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.deep,
        ),
        child: Stack(
          children: [
            // Top-left orange glow (20% 0%) - elipse grande que se estende para direita
            Positioned(
              top: -150,
              left: -50,
              child: Container(
                width: 700,
                height: 550,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.6,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.28),
                      AppColors.primary.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Right magenta glow (100% 40%) - elipse grande que quase toca o laranja
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              right: -150,
              child: Container(
                width: 700,
                height: 600,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.6,
                    colors: [
                      AppColors.magenta.withValues(alpha: 0.20),
                      AppColors.magenta.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Bottom-left blue glow (0% 100%) - elipse 500x400 at esquerda, fundo
            Positioned(
              bottom: -100,
              left: -150,
              child: Container(
                width: 500,
                height: 400,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.5,
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.22),
                      AppColors.secondary.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Noise overlay - textura granulada sutil
  Widget _buildNoiseOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.04,
          child: CustomPaint(
            painter: _NoisePainter(),
          ),
        ),
      ),
    );
  }

  /// Tagline - "Treino é melhor em squad." com gradiente
  Widget _buildTagline() {
    return Column(
      children: [
        // Main tagline
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -1.2,
            ),
            children: [
              const TextSpan(text: 'Treino é melhor\nem '),
              TextSpan(
                text: 'squad',
                style: TextStyle(
                  foreground: Paint()
                    ..shader = AppGradients.hype.createShader(
                      const Rect.fromLTWH(0, 0, 100, 40),
                    ),
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Subtitle
        Text(
          'Desafie amigos, perca peso junto, comemore cada PR.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  /// Email field com ícone
  Widget _buildEmailField() {
    return SFInput(
      controller: _emailController,
      icon: Icons.mail_outline,
      placeholder: 'seu@email.com',
      keyboardType: TextInputType.emailAddress,
    );
  }

  /// Password field com toggle visibility
  Widget _buildPasswordField() {
    return SFInput(
      controller: _passwordController,
      icon: Icons.lock_outline,
      placeholder: 'Senha',
      obscureText: _obscurePassword,
      trailing: GestureDetector(
        onTap: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        child: Icon(
          _obscurePassword ? Icons.visibility : Icons.visibility_off,
          size: 20,
          color: AppColors.textSecondaryDark,
        ),
      ),
    );
  }

  /// Error message container
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Divider com "ou" - EXATO do design
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.borderDark,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'ou',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: AppColors.textTertiaryDark,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.borderDark,
          ),
        ),
      ],
    );
  }

  /// Google icon SVG
  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: _GoogleIconPainter(),
      ),
    );
  }

  /// Toggle entre login e signup
  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? 'Novo por aqui? ' : 'Já tem conta? ',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDark,
          ),
        ),
        GestureDetector(
          onTap: _isLoading
              ? null
              : () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _errorMessage = null;
                  });
                },
          child: Text(
            _isLogin ? 'Cadastre-se' : 'Entrar',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Painter para noise texture
class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < 5000; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para Google icon
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 48;
    canvas.scale(scale);

    // Yellow
    final yellowPaint = Paint()..color = const Color(0xFFFFC107);
    final yellowPath = Path()
      ..moveTo(43.6, 20.1)
      ..lineTo(42, 20.1)
      ..lineTo(42, 20)
      ..lineTo(24, 20)
      ..lineTo(24, 28)
      ..lineTo(35.3, 28)
      ..cubicTo(33.7, 32.7, 29.2, 36, 24, 36)
      ..cubicTo(17.4, 36, 12, 30.6, 12, 24)
      ..cubicTo(12, 17.4, 17.4, 12, 24, 12)
      ..cubicTo(27.1, 12, 29.8, 13.2, 31.9, 15.1)
      ..lineTo(37.6, 9.4)
      ..cubicTo(34, 6.1, 29.3, 4, 24, 4)
      ..cubicTo(12.9, 4, 4, 12.9, 4, 24)
      ..cubicTo(4, 35.1, 12.9, 44, 24, 44)
      ..cubicTo(35.1, 44, 44, 35.1, 44, 24)
      ..cubicTo(44, 22.7, 43.9, 21.4, 43.6, 20.1)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Red
    final redPaint = Paint()..color = const Color(0xFFFF3D00);
    final redPath = Path()
      ..moveTo(6.3, 14.7)
      ..lineTo(12.9, 19.5)
      ..cubicTo(14.6, 15.1, 18.9, 12, 24, 12)
      ..cubicTo(27.1, 12, 29.8, 13.2, 31.9, 15.1)
      ..lineTo(37.6, 9.4)
      ..cubicTo(34, 6.1, 29.3, 4, 24, 4)
      ..cubicTo(16.3, 4, 9.6, 8.3, 6.3, 14.7)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Green
    final greenPaint = Paint()..color = const Color(0xFF4CAF50);
    final greenPath = Path()
      ..moveTo(24, 44)
      ..cubicTo(29.2, 44, 33.9, 42, 37.4, 38.8)
      ..lineTo(31.2, 33.6)
      ..cubicTo(29.2, 35, 26.7, 36, 24, 36)
      ..cubicTo(18.8, 36, 14.4, 32.7, 12.7, 28.1)
      ..lineTo(6.2, 33.1)
      ..cubicTo(9.5, 39.6, 16.2, 44, 24, 44)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Blue
    final bluePaint = Paint()..color = const Color(0xFF1976D2);
    final bluePath = Path()
      ..moveTo(43.6, 20.1)
      ..lineTo(42, 20.1)
      ..lineTo(42, 20)
      ..lineTo(24, 20)
      ..lineTo(24, 28)
      ..lineTo(35.3, 28)
      ..cubicTo(34.5, 30.3, 33, 32.3, 31.2, 33.6)
      ..lineTo(37.4, 38.8)
      ..cubicTo(41.9, 35.6, 44, 30.2, 44, 24)
      ..cubicTo(44, 22.7, 43.9, 21.4, 43.6, 20.1)
      ..close();
    canvas.drawPath(bluePath, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
