import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../models/summary_model.dart';
import '../../models/user_model.dart';
import '../../services/category_service.dart';
import '../../services/transaction_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/auth_service.dart';
import '../../core/formatters.dart';
import '../../ux/theme.dart';
import '../../ux/widgets/category_chart.dart';

class PantallaDashboard extends StatelessWidget {
  final VoidCallback? alTocarVerTodas;

  const PantallaDashboard({super.key, this.alTocarVerTodas});

  @override
  Widget build(BuildContext contexto) {
    final servicioCategorias = ServicioCategorias();
    final servicioTransacciones = ServicioTransacciones();
    final servicioDashboard = ServicioDashboard();
    final servicioAuth = ServicioAutenticacion();
    final idUsuario = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: FutureBuilder<UsuarioModelo?>(
        future: servicioAuth.obtenerDatosUsuario(idUsuario),
        builder: (contexto, snapshotUsuario) {
          final usuario = snapshotUsuario.data;

          return StreamBuilder<List<CategoriaModelo>>(
            stream: servicioCategorias.obtenerCategorias(idUsuario),
            builder: (contexto, snapshotCategorias) {
              if (!snapshotCategorias.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final mapaCategorias = {
                for (var categoria in snapshotCategorias.data!)
                  categoria.idCategoria: categoria,
              };

              return StreamBuilder<List<TransaccionModelo>>(
                stream: servicioTransacciones.obtenerTransacciones(idUsuario),
                builder: (contexto, snapshotTransacciones) {
                  if (snapshotTransacciones.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final todasTransacciones = snapshotTransacciones.data ?? [];
                  final transaccionesMesActual = servicioDashboard
                      .filtrarMesActual(todasTransacciones);
                  final transaccionesMesAnterior = servicioDashboard
                      .filtrarMesAnterior(todasTransacciones);

                  final resumenTotal = servicioDashboard.calcularResumen(
                    todasTransacciones,
                  );
                  final resumenMensual = servicioDashboard.calcularResumen(
                    transaccionesMesActual,
                  );
                  final resumenMesAnterior = servicioDashboard.calcularResumen(
                    transaccionesMesAnterior,
                  );

                  final recientes = todasTransacciones.take(4).toList();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _EncabezadoSaludo(nombre: usuario?.nombreVisible),
                      const SizedBox(height: 20),
                      _TarjetaSaldo(
                        resumenTotal: resumenTotal,
                        resumenMensual: resumenMensual,
                        resumenMesAnterior: resumenMesAnterior,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Gastos por categoría (este mes)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      resumenMensual.gastosPorCategoria.isEmpty
                          ? const _SinDatosGrafica()
                          : GraficaCategorias(
                              gastosPorCategoria:
                                  resumenMensual.gastosPorCategoria,
                              mapaCategorias: mapaCategorias,
                            ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Actividad reciente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (alTocarVerTodas != null)
                            TextButton(
                              onPressed: alTocarVerTodas,
                              child: const Text('Ver todas'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      recientes.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Aún no tienes transacciones registradas',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            )
                          : Column(
                              children: recientes
                                  .map(
                                    (transaccion) => _FilaTransaccionReciente(
                                      transaccion: transaccion,
                                      categoria:
                                          mapaCategorias[transaccion
                                              .idCategoria],
                                    ),
                                  )
                                  .toList(),
                            ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ── Saludo con nombre del usuario y fecha ─────────────────────────────────
class _EncabezadoSaludo extends StatelessWidget {
  final String? nombre;
  const _EncabezadoSaludo({required this.nombre});

  String _saludoSegunHora() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _fechaFormateada() {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final ahora = DateTime.now();
    return '${ahora.day} de ${meses[ahora.month - 1]}';
  }

  @override
  Widget build(BuildContext contexto) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_saludoSegunHora()}, ${nombre?.split(' ').first ?? ''} 👋',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _fechaFormateada(),
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tarjeta de saldo (diseño blanco original) con indicador de tendencia ──
class _TarjetaSaldo extends StatelessWidget {
  final ResumenModelo resumenTotal;
  final ResumenModelo resumenMensual;
  final ResumenModelo resumenMesAnterior;

  const _TarjetaSaldo({
    required this.resumenTotal,
    required this.resumenMensual,
    required this.resumenMesAnterior,
  });

  @override
  Widget build(BuildContext contexto) {
    double? cambioPorcentual;
    if (resumenMesAnterior.balance != 0) {
      cambioPorcentual =
          ((resumenMensual.balance - resumenMesAnterior.balance) /
              resumenMesAnterior.balance.abs()) *
          100;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo total',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  formatearMonto(resumenTotal.balance),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: resumenTotal.balance >= 0
                        ? Colors.green.shade700
                        : Colors.red,
                  ),
                ),
                if (cambioPorcentual != null) ...[
                  const SizedBox(width: 10),
                  _EtiquetaTendencia(porcentaje: cambioPorcentual),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Este mes',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ColumnaMonto(
                  etiqueta: 'Ingresos',
                  monto: resumenMensual.totalIngresos,
                  color: Colors.green,
                  icono: Icons.arrow_upward,
                ),
                _ColumnaMonto(
                  etiqueta: 'Gastos',
                  monto: resumenMensual.totalGastos,
                  color: Colors.red,
                  icono: Icons.arrow_downward,
                ),
                _ColumnaMonto(
                  etiqueta: 'Balance',
                  monto: resumenMensual.balance,
                  color: resumenMensual.balance >= 0
                      ? Colors.green
                      : Colors.red,
                  icono: Icons.account_balance_wallet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EtiquetaTendencia extends StatelessWidget {
  final double porcentaje;
  const _EtiquetaTendencia({required this.porcentaje});

  @override
  Widget build(BuildContext contexto) {
    final esPositivo = porcentaje >= 0;
    final color = esPositivo ? Colors.green.shade700 : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            esPositivo ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 3),
          Text(
            '${porcentaje.abs().toStringAsFixed(0)}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnaMonto extends StatelessWidget {
  final String etiqueta;
  final double monto;
  final Color color;
  final IconData icono;

  const _ColumnaMonto({
    required this.etiqueta,
    required this.monto,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext contexto) {
    return Column(
      children: [
        Icon(icono, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          formatearMonto(monto),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

// ── Estado vacío cuando no hay gastos este mes ────────────────────────────
class _SinDatosGrafica extends StatelessWidget {
  const _SinDatosGrafica();

  @override
  Widget build(BuildContext contexto) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Aún no hay gastos registrados este mes',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

// ── Fila de transacción reciente ──────────────────────────────────────────
class _FilaTransaccionReciente extends StatelessWidget {
  final TransaccionModelo transaccion;
  final CategoriaModelo? categoria;

  const _FilaTransaccionReciente({
    required this.transaccion,
    required this.categoria,
  });

  @override
  Widget build(BuildContext contexto) {
    final esGasto = transaccion.tipo == 'expense';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: categoria?.obtenerColor() ?? Colors.grey,
            child: Icon(
              categoria?.obtenerIcono() ?? Icons.category,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoria?.nombre ?? 'Sin categoría',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${transaccion.fecha.day}/${transaccion.fecha.month}/${transaccion.fecha.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '${esGasto ? '-' : '+'} ${formatearMonto(transaccion.montoConvertido)}',
            style: TextStyle(
              color: esGasto
                  ? TemaSaveFlow.colorGasto
                  : TemaSaveFlow.colorIngreso,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
