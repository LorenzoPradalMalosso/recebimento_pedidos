class Produto {
  int? id; // Pode ser nulo inicialmente
  String nome;
  String descricao;
  double preco;
  String categoria;

  Produto ({
    this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.categoria
  });

  Map<String,dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'categoria': categoria
    };
  }

  factory Produto.fromMap(Map<String,dynamic> map) {
    return Produto(
      id: map['id'], 
      nome: map['nome'], 
      descricao: map['descricao'], 
      preco: map['preco'], 
      categoria: map['categoria']
    );
  }
}