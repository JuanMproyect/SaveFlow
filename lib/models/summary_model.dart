class ResumenModelo {
  final double totalIngresos;
  final double totalGastos;
  final double balance;
  final Map<String, double> gastosPorCategoria; // idCategoria -> monto total

  ResumenModelo({
    required this.totalIngresos,
    required this.totalGastos,
    required this.balance,
    required this.gastosPorCategoria,
  });
}