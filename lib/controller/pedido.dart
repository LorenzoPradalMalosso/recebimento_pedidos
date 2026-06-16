import '../database/database_helper.dart';
import '../model/item_pedido.dart';
import '../model/pedido.dart';

class PedidoController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Pedido>> listarPedidos() => _dbHelper.getPedidos();

  Future<List<Pedido>> listarPedidosFinalizados() =>
      _dbHelper.getPedidosFinalizados();

  Future<int> salvarPedido(Pedido pedido) async {
    if (pedido.id == null) {
      return await _dbHelper.insertPedido(pedido);
    }
    return await _dbHelper.updatePedido(pedido);
  }

  Future<int> removerPedido(int id) => _dbHelper.deletePedido(id);

  Future<Pedido> obterOuCriarPedidoEmAndamento() async {
    final pedidoAberto = await _dbHelper.getPedidoEmAndamento();
    if (pedidoAberto != null) return pedidoAberto;

    final novoPedido = Pedido(
      data: DateTime.now().toIso8601String(),
      valorTotal: 0,
      status: "Em andamento",
    );

    final id = await _dbHelper.insertPedido(novoPedido);
    return Pedido(
      id: id,
      data: novoPedido.data,
      valorTotal: novoPedido.valorTotal,
      status: novoPedido.status,
    );
  }

  Future<Pedido?> obterPedidoEmAndamento() => _dbHelper.getPedidoEmAndamento();

  Future<double> atualizarValorTotal(int pedidoId) async {
    final itens = await _dbHelper.getItensPorPedido(pedidoId);
    final total = calcularValorTotal(itens);
    final pedido = await obterPedidoPorId(pedidoId);

    if (pedido != null) {
      pedido.valorTotal = total;
      await _dbHelper.updatePedido(pedido);
    }

    return total;
  }

  Future<bool> finalizarPedido() async {
    final pedido = await _dbHelper.getPedidoEmAndamento();
    if (pedido == null || pedido.id == null) return false;

    final itens = await _dbHelper.getItensPorPedido(pedido.id!);
    if (itens.isEmpty) return false;

    pedido.valorTotal = calcularValorTotal(itens);
    pedido.data = DateTime.now().toIso8601String();
    pedido.status = "Finalizado";

    return await _dbHelper.updatePedido(pedido) > 0;
  }

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
