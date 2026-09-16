import '../models/transaction_model.dart';
import '../models/summary_model.dart';

class ServicioDashboard {
  // Calcula el resumen financiero a partir de una lista de transacciones.
  // Es una función pura: no toca Firestore, solo procesa datos ya cargados.
  ResumenModelo calcularResumen(List<TransaccionModelo> transacciones) {
    double totalIngresos = 0;
    double totalGastos = 0;
    final Map<String, double> gastosPorCategoria = {};

    for (var transaccion in transacciones) {
      if (transaccion.tipo == 'income') {
        totalIngresos += transaccion.montoConvertido;
      } else {
        totalGastos += transaccion.montoConvertido;
        gastosPorCategoria.update(
          transaccion.idCategoria,
          (montoActual) => montoActual + transaccion.montoConvertido,
          ifAbsent: () => transaccion.montoConvertido,
        );
      }
    }

    return ResumenModelo(
      totalIngresos: totalIngresos,
      totalGastos: totalGastos,
      balance: totalIngresos - totalGastos,
      gastosPorCategoria: gastosPorCategoria,
    );
  }

  // Filtra transacciones solo del mes actual (útil para el balance mensual)
  List<TransaccionModelo> filtrarMesActual(
    List<TransaccionModelo> transacciones,
  ) {
    final ahora = DateTime.now();
    return transacciones.where((transaccion) {
      return transaccion.fecha.year == ahora.year &&
          transaccion.fecha.month == ahora.month;
    }).toList();
  }
}
