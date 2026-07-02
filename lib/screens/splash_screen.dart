import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edumov/services/config_service.dart';
import 'home_screen.dart';
import 'setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final ConfigService _configService = ConfigService();

  @override
  void initState() {
    super.initState();
    
    // Configurar animações
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Iniciar animação
    _animationController.forward();

    // Aguardar a animação e depois verificar o setup
    _verificarSetupAposAnimacao();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ MÉTODO NOVO: Verifica o setup após a animação
  Future<void> _verificarSetupAposAnimacao() async {
    // Aguarda 3 segundos (tempo da animação)
    await Future.delayed(const Duration(seconds: 3));
    
    // Verifica se o setup já foi concluído
    await _verificarENavegar();
  }

  // ✅ MÉTODO NOVO: Verifica configuração e navega para tela correta
  Future<void> _verificarENavegar() async {
    try {
    final config = await _configService.buscarConfiguracao();
    
    if (!mounted) return;
    
    // Se não tem configuração (primeira vez)
    if (config == null || !config.setupConcluido) {
      Navigator.pushReplacementNamed(context, '/setup');
      return;
    }
    
    // Se tem configuração mas não tem assinatura ativa
    if (!config.isAssinaturaValida) {
      Navigator.pushReplacementNamed(context, '/assinatura');
      return;
    }
    
    // Tudo ok - vai para Home
    Navigator.pushReplacementNamed(context, '/home');
    
  } catch (e) {
    print('Erro ao verificar setup: $e');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/setup');
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    // Forçar modo imersivo (tela cheia)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A73E8),
              const Color(0xFF00BFA5),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/imagens/eduMov_logo.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Nome do App
                const Text(
                  'EDU MOV',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 6,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Slogan
                const Text(
                  'Educação em Movimento',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 3,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Loading
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}