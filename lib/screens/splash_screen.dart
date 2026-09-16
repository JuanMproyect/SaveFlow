import 'package:flutter/material.dart';
import '../main.dart' show PantallaInicial;
import '../ux/theme.dart';

class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _EstadoPantallaCarga();
}

class _EstadoPantallaCarga extends State<PantallaCarga>
    with SingleTickerProviderStateMixin {
  late AnimationController _controlador;
  late Animation<double> _animacionEscala;
  late Animation<double> _animacionOpacidad;

  @override
  void initState() {
    super.initState();

    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Efecto "pop": empieza pequeño y rebota hasta su tamaño normal
    _animacionEscala = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controlador, curve: Curves.elasticOut),
    );

    _animacionOpacidad = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controlador,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _controlador.forward();

    // Tiempo mínimo de splash, luego navega a la pantalla que decide
    // si mostrar Login o el Dashboard (según el estado de sesión real)
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (contexto) => const PantallaInicial()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [TemaSaveFlow.verdeEsmeralda, TemaSaveFlow.azulMarino],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo con efecto pop (reemplazar por Image.asset cuando esté listo el logo real)
              ScaleTransition(
                scale: _animacionEscala,
                child: FadeTransition(
                  opacity: _animacionOpacidad,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.savings_rounded,
                      size: 52,
                      color: TemaSaveFlow.verdeEsmeralda,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _animacionOpacidad,
                child: const Text(
                  'SaveFlow',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _animacionOpacidad,
                child: Text(
                  'Tu flujo financiero, bajo control',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}