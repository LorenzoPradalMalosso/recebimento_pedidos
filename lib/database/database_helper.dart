// ignore_for_file: unnecessary_import

import 'package:path/path.dart';
import 'package:recebimento_pedidos/model/item_pedido.dart';
import 'package:recebimento_pedidos/model/pedido.dart';
import 'package:recebimento_pedidos/model/produto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {
  // Transforma essa classe em singleton
  // Não permite instanciar outro obj enquanto um obj estiver ativo
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Construir o Singleton
  // Essa Classe não possui um Construtor Normal,
  // Ele precisa do factory para estabelecer a conexão
  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  // Conector do Banco de Dados
  Database? _database; // Privado

  // get database
  Future<Database> get database async{
    if(_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), "loja.db");

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (db, version) async {
        // Tabela de produtos
        await db.execute('''
          CREATE TABLE produtos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            descricao TEXT,
            preco REAL,
            categoria TEXT
          )
        ''');

        // Tabela de pedidos
        await db.execute('''
          CREATE TABLE pedidos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT,
            valorTotal REAL,
            status TEXT
          )
        ''');

        // Tabela de itens do pedido
        await db.execute('''
          CREATE TABLE itensPedido(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pedidoId INTEGER,
            produtoId INTEGER,
            quantidade INTEGER,
            precoUnitario REAL,
            FOREIGN KEY(pedidoId) REFERENCES pedidos(id) ON DELETE CASCADE,
            FOREIGN KEY(produtoId) REFERENCES produtos(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ==========================
  // CRUD PRODUTOS
  // ==========================

  Future<int> insertProduto(Produto produto) async =>
      (await database).insert("produtos", produto.toMap());

  Future<List<Produto>> getProdutos() async {
    final List<Map<String, dynamic>> maps =
        await (await database).query(
      "produtos",
      orderBy: "nome ASC",
    );

    return List.generate(
      maps.length,
      (i) => Produto.fromMap(maps[i]),
    );
  }

  Future<int> updateProduto(Produto produto) async =>
      (await database).update(
        "produtos",
        produto.toMap(),
        where: "id = ?",
        whereArgs: [produto.id],
      );

  Future<int> deleteProduto(int id) async =>
      (await database).delete(
        "produtos",
        where: "id = ?",
        whereArgs: [id],
      );

  // ==========================
  // CRUD PEDIDOS
  // ==========================

  Future<int> insertPedido(Pedido pedido) async =>
      (await database).insert("pedidos", pedido.toMap());

  Future<List<Pedido>> getPedidos() async {
    final List<Map<String, dynamic>> maps =
        await (await database).query(
      "pedidos",
      orderBy: "data DESC",
    );

    return List.generate(
      maps.length,
      (i) => Pedido.fromMap(maps[i]),
    );
  }

  Future<int> updatePedido(Pedido pedido) async =>
      (await database).update(
        "pedidos",
        pedido.toMap(),
        where: "id = ?",
        whereArgs: [pedido.id],
      );

  Future<int> deletePedido(int id) async =>
      (await database).delete(
        "pedidos",
        where: "id = ?",
        whereArgs: [id],
      );

  // ==========================
  // CRUD ITENS DO PEDIDO
  // ==========================

  Future<int> insertItemPedido(ItemPedido item) async =>
      (await database).insert("itensPedido", item.toMap());

  Future<List<ItemPedido>> getItensPorPedido(int pedidoId) async {
    final List<Map<String, dynamic>> maps =
        await (await database).query(
      "itensPedido",
      where: "pedidoId = ?",
      whereArgs: [pedidoId],
    );

    return List.generate(
      maps.length,
      (i) => ItemPedido.fromMap(maps[i]),
    );
  }

  Future<int> updateItemPedido(ItemPedido item) async =>
      (await database).update(
        "itensPedido",
        item.toMap(),
        where: "id = ?",
        whereArgs: [item.id],
      );

  Future<int> deleteItemPedido(int id) async =>
      (await database).delete(
        "itensPedido",
        where: "id = ?",
        whereArgs: [id],
      );
}