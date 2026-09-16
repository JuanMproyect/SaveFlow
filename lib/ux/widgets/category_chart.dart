import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/category_model.dart';
import '../../core/formatters.dart';

class GraficaCategorias extends StatelessWidget {
  final Map<String, double> gastosPorCategoria;
  final Map<String, CategoriaModelo> mapaCategorias;

  const GraficaCategorias({
    super.key,
    required this.gastosPorCategoria,
    required this.mapaCategorias,
  });

  @override
  Widget build(BuildContext contexto) {
    final totalGastos = gastosPorCategoria.values.fold(
      0.0,
      (suma, valor) => suma + valor,
    );

    // Ordenamos de mayor a menor para que la leyenda sea más legible
    final entradasOrdenadas = gastosPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: entradasOrdenadas.map((entrada) {
                final categoria = mapaCategorias[entrada.key];
                final porcentaje = (entrada.value / totalGastos) * 100;

                return PieChartSectionData(
                  value: entrada.value,
                  color: categoria?.obtenerColor() ?? Colors.grey,
                  title: '${porcentaje.toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Leyenda debajo de la gráfica
        Column(
          children: entradasOrdenadas.map((entrada) {
            final categoria = mapaCategorias[entrada.key];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: categoria?.obtenerColor() ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(categoria?.nombre ?? 'Sin categoría')),
                  Text(
                    formatearMonto(entrada.value),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
