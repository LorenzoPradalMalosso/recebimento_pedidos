import 'package:flutter/material.dart';
import 'package:recebimento_pedidos/controller/item_pedido.dart';
import 'package:recebimento_pedidos/controller/pedido.dart';
import 'package:recebimento_pedidos/model/produto.dart';
import 'package:recebimento_pedidos/view/add_produto_screen.dart';
import 'package:recebimento_pedidos/view/pedido_screen.dart';

class ProdutoDetailScreen extends StatefulWidget {
  final Produto produto;

  const ProdutoDetailScreen({super.key, required this.produto});

  @override
  State<ProdutoDetailScreen> createState() => _ProdutoDetailScreenState();
}

class _ProdutoDetailScreenState extends State<ProdutoDetailScreen> {
  final PedidoController _pedidoController = PedidoController();
  final ItemPedidoController _itemPedidoController = ItemPedidoController();

  int _quantidade = 1;

  String _formatarPreco(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}";
  }

  void _alterarQuantidade(int valor) {
    final novaQuantidade = _quantidade + valor;
    if (novaQuantidade <= 0) return;

    setState(() {
      _quantidade = novaQuantidade;
    });
  }

  void _adicionarAoCarrinho() async {
    final pedido = await _pedidoController.obterOuCriarPedidoEmAndamento();

    await _itemPedidoController.adicionarProdutoAoPedido(
      pedido.id!,
      widget.produto,
      _quantidade,
    );
    await _pedidoController.atualizarValorTotal(pedido.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Produto adicionado ao carrinho!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;

    return Scaffold(
      appBar: AppBar(
        title: Text(produto.nome),
        actions: [
          IconButton(
            tooltip: "Editar produto",
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final atualizado = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProdutoScreen(produto: produto),
                ),
              );

              if (!context.mounted || atualizado != true) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: Text(
                produto.nome,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(produto.categoria),
              trailing: Text(
                _formatarPreco(produto.preco),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(produto.descricao),
            ),
            const SizedBox(height: 16),
            const Text(
              "Quantidade",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () => _alterarQuantidade(-1),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  _quantidade.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => _alterarQuantidade(1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const Spacer(),
                Text(
                  _formatarPreco(produto.preco * _quantidade),
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _adicionarAoCarrinho,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Adicionar ao Carrinho"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PedidoScreen()),
              ),
              icon: const Icon(Icons.shopping_cart),
              label: const Text("Ver Pedido"),
            ),
          ],
        ),
      ),
    );
  }
}
