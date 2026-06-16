import '../database/database_helper.dart';
import '../model/item_pedido.dart';
import '../model/produto.dart';

class ItemPedidoController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<ItemPedido>> listarItensPorPedido(int pedidoId) =>
      _dbHelper.getItensPorPedido(pedidoId);

  Future<int> adicionarItem(ItemPedido item) =>
      _dbHelper.insertItemPedido(item);

  Future<int> atualizarItem(ItemPedido item) =>
      _dbHelper.updateItemPedido(item);

  Future<int> removerItem(int id) => _dbHelper.deleteItemPedido(id);

  Future<List<Map<String, dynamic>>> listarItensDetalhadosPorPedido(
    int pedidoId,
  ) {
    return _dbHelper.getItensDetalhadosPorPedido(pedidoId);
  }

  Future<int> adicionarProdutoAoPedido(
    int pedidoId,
    Produto produto,
    int quantidade,
  ) async {
    final itemAtual = await _dbHelper.getItemPorPedidoProduto(
      pedidoId,
      produto.id!,
    );

    if (itemAtual != null) {
      itemAtual.quantidade += quantidade;
      return atualizarItem(itemAtual);
    }

    return adicionarItem(
      ItemPedido(
        pedidoId: pedidoId,
        produtoId: produto.id!,
        quantidade: quantidade,
        precoUnitario: produto.preco,
      ),
    );
  }

  double calcularSubtotal(ItemPedido item) {
    return item.precoUnitario * item.quantidade;
  }

  bool validarItem(ItemPedido item) {
    return item.pedidoId > 0 &&
        item.produtoId > 0 &&
        item.quantidade > 0 &&
        item.precoUnitario > 0;
  }

  Future<int> atualizarQuantidade(ItemPedido item, int quantidade) {
    item.quantidade = quantidade;
    return atualizarItem(item);
  }
}
