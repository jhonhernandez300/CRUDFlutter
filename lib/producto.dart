class Producto {
  int? id;
  String producto;
  double valor;
  String cliente;
  String metodoDePago;
  String fecha;

  Producto({
    this.id,
    required this.producto,
    required this.valor,
    required this.cliente,
    required this.metodoDePago,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto': producto,
      'valor': valor,
      'cliente': cliente,
      'metodoDePago': metodoDePago,
      'fecha': fecha,
    };
  }
}
