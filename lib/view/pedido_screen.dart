import 'package:flutter/material.dart';
import 'package:recebimento_pedidos/controller/item_pedido.dart';
import 'package:recebimento_pedidos/controller/pedido.dart';
import 'package:recebimento_pedidos/model/item_pedido.dart';
import 'package:recebimento_pedidos/model/pedido.dart';

class PedidoScreen extends StatefulWidget {
  const PedidoScreen({super.key});

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  final PedidoController _pedidoController = PedidoController();
  final ItemPedidoController _itemPedidoController = ItemPedidoController();

  String _formatarPreco(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}";
  }

  Future<Pedido?> _carregarPedido() {
    return _pedidoController.obterPedidoEmAndamento();
  }

  Future<void> _atualizarQuantidade(
    Pedido pedido,
    Map<String, dynamic> itemMap,
    int novaQuantidade,
  ) async {
    final item = ItemPedido.fromMap(itemMap);

    if (novaQuantidade <= 0) {
      await _itemPedidoController.removerItem(item.id!);
    } else {
      await _itemPedidoController.atualizarQuantidade(item, novaQuantidade);
    }

    await _pedidoController.atualizarValorTotal(pedido.id!);
    setState(() {});
  }

  void _finalizarPedido(Pedido pedido) async {
    final sucesso = await _pedidoController.finalizarPedido();

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pedido finalizado com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Adicione pelo menos um item antes de finalizar."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildItens(Pedido pedido) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _itemPedidoController.listarItensDetalhadosPorPedido(pedido.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final itens = snapshot.data!;
        if (itens.isEmpty) {
          return const Expanded(
            child: Center(child: Text("O pedido ainda não possui itens.")),
          );
        }

        final total = itens.fold<double>(0, (valor, item) {
          return valor + item["precoUnitario"] * item["quantidade"];
        });

        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: itens.length,
                  itemBuilder: (context, i) {
                    final item = itens[i];
                    final subtotal = item["precoUnitario"] * item["quantidade"];

                    return Card(
                      child: ListTile(
                        title: Text(item["produtoNome"]),
                        subtitle: Text(
                          "${item["quantidade"]} x ${_formatarPreco(item["precoUnitario"])}",
                        ),
                        trailing: SizedBox(
                          width: 170,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => _atualizarQuantidade(
                                  pedido,
                                  item,
                                  item["quantidade"] - 1,
                                ),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(_formatarPreco(subtotal)),
                              IconButton(
                                onPressed: () => _atualizarQuantidade(
                                  pedido,
                                  item,
                                  item["quantidade"] + 1,
                                ),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Total: ${_formatarPreco(total)}",
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _finalizarPedido(pedido),
                      icon: const Icon(Icons.check),
                      label: const Text("Finalizar Pedido"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pedido em Andamento")),
      body: FutureBuilder<Pedido?>(
        future: _carregarPedido(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedido = snapshot.data;
          if (pedido == null || pedido.id == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Nenhum pedido em andamento. Adicione um produto pelo menu.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text("Pedido #${pedido.id}"),
                subtitle: Text(pedido.status),
              ),
              const Divider(),
              _buildItens(pedido),
            ],
          );
        },
      ),
    );
  }
}
