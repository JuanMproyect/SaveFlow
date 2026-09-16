import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../models/summary_model.dart';
import '../../services/category_service.dart';
import '../../services/transaction_service.dart';
import '../../services/dashboard_service.dart';
import '../../core/formatters.dart';
import '../../ux/widgets/category_chart.dart';

class PantallaDashboard extends StatelessWidget {
  const PantallaDashboard({super.key});

  @override
  Widget build(BuildContext contexto) {
    final servicioCategorias = ServicioCategorias();
    final servicioTransacciones = ServicioTransacciones();
    final servicioDashboard = ServicioDashboard();
    final idUsuario = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: StreamBuilder<List<CategoriaModelo>>(
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
              final transaccionesMesActual = servicioDashboard.filtrarMesActual(
                todasTransacciones,
              );

              final resumenTotal = servicioDashboard.calcularResumen(
                todasTransacciones,
              );
              final resumenMensual = servicioDashboard.calcularResumen(
                transaccionesMesActual,
              );

              return RefreshIndicator(
                onRefresh: () async {}, // el StreamBuilder ya refresca solo
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _TarjetaSaldo(
                      resumenTotal: resumenTotal,
                      resumenMensual: resumenMensual,
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Tarjeta de saldo total y balance mensual ──────────────────────────────
class _TarjetaSaldo extends StatelessWidget {
  final ResumenModelo resumenTotal;
  final ResumenModelo resumenMensual;

  const _TarjetaSaldo({
    required this.resumenTotal,
    required this.resumenMensual,
  });

  @override
  Widget build(BuildContext contexto) {
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
