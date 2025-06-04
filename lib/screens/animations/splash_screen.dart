import 'package:flutter/material.dart';
import '../login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 3 secondes au total
    );

    // Animation de position (gauche -> centre -> droite)
    _positionAnimation = TweenSequence<Offset>([
      // De gauche au centre en 1s
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-1.0, 0.0), // À gauche
          end: Offset.zero,               // Au centre
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1.0, // 1/3 de la durée totale
      ),
      // Pause au centre pendant 1s
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero, // Centre
          end: Offset.zero,   // Toujours au centre
        ),
        weight: 1.0, // 1/3 de la durée totale
      ),
      // Du centre vers la droite en 1s
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,             // Centre
          end: const Offset(1.0, 0.0),   // À droite
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 1.0, // 1/3 de la durée totale
      ),
    ]).animate(_controller);


    // Animation d'opacité (fondu à l'entrée et à la sortie)
    _opacityAnimation = TweenSequence<double>([
      // Apparition en 1s
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1.0,
      ),
      // Reste visible pendant 1s
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 1.0,
      ),
      // Disparition en 1s
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1.0,
      ),
    ]).animate(_controller);

    // Démarrer l'animation
    _controller.forward();

    // Aller à l'écran de connexion après l'animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Petit délai pour laisser l'animation se terminer proprement
        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 1000),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SlideTransition(
              position: _positionAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Votre logo
                    Image.asset(
                      'assets/images/gymtech_logo.png', // Assurez-vous d'avoir cette image dans votre dossier assets
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
