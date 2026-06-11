import '../database/database_helper.dart';
import '../model/item_pedido.dart';
import '../model/pedido.dart';

class PedidoController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Pedido>> listarPedidos() => _dbHelper.getPedidos();

  Future<int> salvarPedido(Pedido pedido) async {
    if (pedido.id == null) {
      return await _dbHelper.insertPedido(pedido);
    }
    return await _dbHelper.updatePedido(pedido);
  }

  Future<int> removerPedido(int id) => _dbHelper.deletePedido(id);

  double calcularValorTotal(List<ItemPedido> itens) {
    return itens.fold(0.0, (total, item) {
      return total + item.precoUnitario * item.quantidade;
    });
  }

  bool validarPedido(Pedido pedido) {
    return pedido.data.trim().isNotEmpty &&
        pedido.valorTotal >= 0 &&
        pedido.status.trim().isNotEmpty;
  }

  Future<Pedido?> obterPedidoPorId(int id) async {
    final pedidos = await listarPedidos();
    for (var pedido in pedidos) {
      if (pedido.id == id) {
        return pedido;
      }
    }
    return null;
  }
}
