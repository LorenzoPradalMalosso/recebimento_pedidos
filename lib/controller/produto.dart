import '../database/database_helper.dart';
import '../model/produto.dart';

class ProdutoController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Produto>> listarProdutos() => _dbHelper.getProdutos();

  Future<int> salvarProduto(Produto produto) async {
    if (produto.id == null) {
      return await _dbHelper.insertProduto(produto);
    }
    return await _dbHelper.updateProduto(produto);
  }

  Future<int> removerProduto(int id) => _dbHelper.deleteProduto(id);

  bool validarProduto(Produto produto) {
    return produto.nome.trim().isNotEmpty &&
        produto.descricao.trim().isNotEmpty &&
        produto.preco > 0 &&
        produto.categoria.trim().isNotEmpty;
  }

  Future<Produto?> obterProdutoPorId(int id) async {
    final produtos = await listarProdutos();
    for (var produto in produtos) {
      if (produto.id == id) {
        return produto;
      }
    }
    return null;
  }
}
