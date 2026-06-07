import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _emblemScale;
  late Animation<double> _emblemOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _dividerWidth;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _btnSlide;
  late Animation<double> _btnOpacity;

  // Moved out of initState as a proper class method
  CurvedAnimation _curve(Interval interval) =>
      CurvedAnimation(parent: _controller, curve: interval);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();

    _emblemScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.25, curve: Curves.elasticOut)));

    _emblemOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        _curve(const Interval(0.0, 0.15)));

    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero).animate(
            _curve(const Interval(0.18, 0.38, curve: Curves.easeOut)));

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        _curve(const Interval(0.18, 0.38)));

    _titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
            _curve(const Interval(0.28, 0.52, curve: Curves.easeOut)));

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        _curve(const Interval(0.28, 0.52)));

    _dividerWidth = Tween<double>(begin: 0.0, end: 80.0).animate(
        _curve(const Interval(0.52, 0.68, curve: Curves.easeOut)));

    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
            _curve(const Interval(0.62, 0.78, curve: Curves.easeOut)));

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        _curve(const Interval(0.62, 0.78)));

    _btnSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
            _curve(const Interval(0.78, 1.0, curve: Curves.easeOut)));

    _btnOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        _curve(const Interval(0.78, 1.0)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emblem
                    FadeTransition(
                      opacity: _emblemOpacity,
                      child: ScaleTransition(
                        scale: _emblemScale,
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // "République du Cameroun"
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: Text(
                          'RÉPUBLIQUE DU CAMEROUN',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 3,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Main title
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                            children: [
                              const TextSpan(text: 'Bienvenue à la\n'),
                              TextSpan(
                                text: 'Commune de Bot-Makak',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFF90CAF9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Animated divider
                    AnimatedBuilder(
                      animation: _dividerWidth,
                      builder: (_, __) => Container(
                        width: _dividerWidth.value,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tagline
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: SlideTransition(
                        position: _taglineSlide,
                        child: Text(
                          "Votre portail officiel pour les services administratifs,\nl'état civil et la gestion municipale.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.75),
                            height: 1.65,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // CTA button
                    FadeTransition(
                      opacity: _btnOpacity,
                      child: SlideTransition(
                        position: _btnSlide,
                        child: SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1565C0),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Accéder au portail',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer note
                    FadeTransition(
                      opacity: _btnOpacity,
                      child: Text(
                        'COMMUNE DE BOT-MAKAK · RÉGION DU CENTRE',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}