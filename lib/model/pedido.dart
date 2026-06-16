class Pedido {
  int? id; // Pode ser nulo inicialmente
  String data;
  double valorTotal;
  String status;

  Pedido({
    this.id,
    required this.data,
    required this.valorTotal,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'data': data, 'valorTotal': valorTotal, 'status': status};
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      data: map['data'],
      valorTotal: map['valorTotal'],
      status: map['status'],
    );
  }
}
