class Participante {
  final String id;
  final String nome;

  Participante({
    required this.id,
    required this.nome,
  });

  Participante copyWith({String? nome}) {
    return Participante(
      id: id,
      nome: nome ?? this.nome,
    );
  }  
}

class Artigo {
  final String id;
  final String nome;
  final double preco;
  final double quantidade;
  final Map<String, double> participantePorcentagem;

  Artigo({
    required this.id,
    required this.nome,
    required this.preco,
    required this.quantidade,
    this.participantePorcentagem = const {},
  });

  Artigo copyWith({
    String? nome,
    double? preco,
    double? quantidade,
    Map<String, double>? participantePorcentagem,
  }) {
    return Artigo(
      id: id,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      quantidade: quantidade ?? this.quantidade,
      participantePorcentagem:
          participantePorcentagem ?? this.participantePorcentagem,
    );
  }

  double get totalPrice => preco * quantidade;
}

class ArtigoDetalhado {
  final String nome;
  final double valor;
  final double quantidade;

  ArtigoDetalhado({
    required this.nome,
    required this.valor,
    required this.quantidade,
  });
}
