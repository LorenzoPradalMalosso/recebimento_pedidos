import 'package:flutter/material.dart';
import 'package:recebimento_pedidos/controller/item_pedido.dart';
import 'package:recebimento_pedidos/controller/pedido.dart';
import 'package:recebimento_pedidos/model/pedido.dart';

class PedidosFinalizadosScreen extends StatefulWidget {
  const PedidosFinalizadosScreen({super.key});

  @override
  State<PedidosFinalizadosScreen> createState() =>
      _PedidosFinalizadosScreenState();
}

class _PedidosFinalizadosScreenState extends State<PedidosFinalizadosScreen> {
  final PedidoController _pedidoController = PedidoController();
  final ItemPedidoController _itemPedidoController = ItemPedidoController();

  String _formatarPreco(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}";
  }

  String _formatarData(String data) {
    final dataPedido = DateTime.tryParse(data);
    if (dataPedido == null) return data;

    final dia = dataPedido.day.toString().padLeft(2, '0');
    final mes = dataPedido.month.toString().padLeft(2, '0');
    final ano = dataPedido.year.toString();
    final hora = dataPedido.hour.toString().padLeft(2, '0');
    final minuto = dataPedido.minute.toString().padLeft(2, '0');

    return "$dia/$mes/$ano $hora:$minuto";
  }

  void _abrirDetalhes(Pedido pedido) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: _itemPedidoController.listarItensDetalhadosPorPedido(
          pedido.id!,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final itens = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Pedido #${pedido.id}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(_formatarData(pedido.data)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: itens.length,
                    itemBuilder: (context, i) {
                      final item = itens[i];
                      final subtotal =
                          item["precoUnitario"] * item["quantidade"];

                      return ListTile(
                        title: Text(item["produtoNome"]),
                        subtitle: Text(
                          "${item["quantidade"]} x ${_formatarPreco(item["precoUnitario"])}",
                        ),
                        trailing: Text(_formatarPreco(subtotal)),
                      );
                    },
                  ),
                ),
                Text(
                  "Total: ${_formatarPreco(pedido.valorTotal)}",
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pedidos Finalizados")),
      body: FutureBuilder<List<Pedido>>(
        future: _pedidoController.listarPedidosFinalizados(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data!;
          if (pedidos.isEmpty) {
            return const Center(
              child: Text("Nenhum pedido finalizado até o momento."),
            );
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, i) {
              final pedido = pedidos[i];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text("Pedido #${pedido.id}"),
                  subtitle: Text(_formatarData(pedido.data)),
                  trailing: Text(_formatarPreco(pedido.valorTotal)),
                  onTap: () => _abrirDetalhes(pedido),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
