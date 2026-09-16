import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../categories/categories_screen.dart';
import '../../main.dart' show modoTemaGlobal;

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _EstadoPantallaPerfil();
}

class _EstadoPantallaPerfil extends State<PantallaPerfil> {
  final ServicioAutenticacion _servicioAuth = ServicioAutenticacion();

  @override
  Widget build(BuildContext contexto) {
    final idUsuario = FirebaseAuth.instance.currentUser!.uid;
    final colorPrimario = Theme.of(contexto).colorScheme.primary;
    final colorSecundario = Theme.of(contexto).colorScheme.secondary;

    return Scaffold(
      body: FutureBuilder<UsuarioModelo?>(
        future: _servicioAuth.obtenerDatosUsuario(idUsuario),
        builder: (contexto, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final usuario = snapshot.data;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── Encabezado con gradiente y avatar ──────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, bottom: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorPrimario, colorSecundario],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: Text(
                        usuario?.nombreVisible.isNotEmpty == true
                            ? usuario!.nombreVisible[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: colorPrimario,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      usuario?.nombreVisible ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario?.correo ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Sección: Cuenta ─────────────────────────────────────
              _EncabezadoSeccion(texto: 'Cuenta'),
              _TarjetaOpcion(
                icono: Icons.attach_money,
                titulo: 'Moneda base',
                valor: usuario?.monedaBase ?? '—',
              ),
              _TarjetaOpcion(
                icono: Icons.category,
                titulo: 'Gestionar categorías',
                mostrarFlecha: true,
                alTocar: () => Navigator.push(
                  contexto,
                  MaterialPageRoute(
                    builder: (contexto) => const PantallaCategorias(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Sección: Ajustes ─────────────────────────────────────
              _EncabezadoSeccion(texto: 'Ajustes'),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: modoTemaGlobal,
                builder: (contexto, modoActual, _) {
                  return _TarjetaOpcion(
                    icono: modoActual == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    titulo: 'Modo oscuro',
                    trailing: Switch(
                      value: modoActual == ThemeMode.dark,
                      activeColor: colorPrimario,
                      onChanged: (activado) {
                        modoTemaGlobal.value = activado
                            ? ThemeMode.dark
                            : ThemeMode.light;
                      },
                    ),
                  );
                },
              ),
              _TarjetaOpcion(
                icono: Icons.language,
                titulo: 'Idioma',
                valor: 'Español',
                mostrarFlecha: true,
                alTocar: () => _mostrarProximamente(contexto),
              ),
              _TarjetaOpcion(
                icono: Icons.info_outline,
                titulo: 'Sobre nosotros',
                mostrarFlecha: true,
                alTocar: () => _mostrarDialogoSobreNosotros(contexto),
              ),

              const SizedBox(height: 24),

              // ── Botón cerrar sesión ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton.icon(
                  onPressed: () => _servicioAuth.cerrarSesion(),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Versión final 2.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  void _mostrarProximamente(BuildContext contexto) {
    ScaffoldMessenger.of(contexto).showSnackBar(
      const SnackBar(content: Text('Por ahora solo disponible en Español')),
    );
  }

  void _mostrarDialogoSobreNosotros(BuildContext contexto) {
    showDialog(
      context: contexto,
      builder: (contextoDialogo) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sobre nosotros'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SafeFlow es un proyecto universitario desarrollado por Juan Morel.',
            ),
            SizedBox(height: 12),
            Text(
              '(Centro Universitario Tecnológico CEUTEC)',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares del perfil ─────────────────────────────────────────

class _EncabezadoSeccion extends StatelessWidget {
  final String texto;
  const _EncabezadoSeccion({required this.texto});

  @override
  Widget build(BuildContext contexto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TarjetaOpcion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? valor;
  final Widget? trailing;
  final bool mostrarFlecha;
  final VoidCallback? alTocar;

  const _TarjetaOpcion({
    required this.icono,
    required this.titulo,
    this.valor,
    this.trailing,
    this.mostrarFlecha = false,
    this.alTocar,
  });

  @override
  Widget build(BuildContext contexto) {
    final colorPrimario = Theme.of(contexto).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colorPrimario.withOpacity(0.12),
            child: Icon(icono, color: colorPrimario, size: 20),
          ),
          title: Text(titulo),
          trailing:
              trailing ??
              (valor != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          valor!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (mostrarFlecha)
                          const Icon(Icons.chevron_right, size: 20),
                      ],
                    )
                  : (mostrarFlecha
                        ? const Icon(Icons.chevron_right, size: 20)
                        : null)),
          onTap: alTocar,
        ),
      ),
    );
  }
}
