import 'package:flutter/material.dart';
import 'package:recebimento_pedidos/controller/produto.dart';
import 'package:recebimento_pedidos/model/produto.dart';
import 'package:recebimento_pedidos/view/add_produto_screen.dart';
import 'package:recebimento_pedidos/view/pedido_screen.dart';
import 'package:recebimento_pedidos/view/pedidos_finalizados_screen.dart';
import 'package:recebimento_pedidos/view/produto_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProdutoController _controller = ProdutoController();

  String _formatarPreco(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}";
  }

  void _atualizarLista() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu de Produtos"),
        actions: [
          IconButton(
            tooltip: "Pedidos finalizados",
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PedidosFinalizadosScreen(),
              ),
            ),
          ),
          IconButton(
            tooltip: "Pedido em andamento",
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PedidoScreen()),
            ).then((value) => _atualizarLista()),
          ),
        ],
      ),
      body: FutureBuilder<List<Produto>>(
        future: _controller.listarProdutos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final produtos = snapshot.data!;
          if (produtos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Nenhum produto cadastrado. Toque no botão + para começar.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, i) {
              final produto = produtos[i];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.fastfood),
                  title: Text(produto.nome),
                  subtitle: Text("${produto.categoria} - ${produto.descricao}"),
                  trailing: Text(_formatarPreco(produto.preco)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProdutoDetailScreen(produto: produto),
                    ),
                  ).then((value) => _atualizarLista()),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddProdutoScreen()),
        ).then((value) => _atualizarLista()),
      ),
    );
  }
}
