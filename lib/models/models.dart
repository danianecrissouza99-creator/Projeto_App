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

class Conta {
  final List<Participante> participantes;
  final List<Artigo> artigos;

  Conta({
    required this.participantes,
    required this.artigos,
  });

  Conta copyWith({
    List<Participante>? participantes,
    List<Artigo>? artigos,
  }) {
    return Conta(
      participantes: participantes ?? this.participantes,
      artigos: artigos ?? this.artigos,
    );
  }

  bool get isValid =>
      participantes.length >= 2 &&
      artigos.isNotEmpty &&
      artigos.every((a) => a.preco > 0 && a.quantidade > 0);

  Map<String, double> calcularTotalPorParticipante() {
    final totaisPorParticipante = <String, double>{};

    for (final participante in participantes) {
      totaisPorParticipante[participante.id] = 0.0;
    }

    for (final artigo in artigos) {
      if (artigo.participantePorcentagem.isEmpty) {
        // Dividir igualmente entre todos os participantes
        final valorPorPessoa = artigo.totalPrice / participantes.length;
        for (final participante in participantes) {
          totaisPorParticipante[participante.id] =
              (totaisPorParticipante[participante.id] ?? 0) + valorPorPessoa;
        }
      } else {
        // Dividir de acordo com as porcentagens
        for (final entry in artigo.participantePorcentagem.entries) {
          final participanteId = entry.key;
          final porcentagem = entry.value;
          totaisPorParticipante[participanteId] =
              (totaisPorParticipante[participanteId] ?? 0) +
                  (artigo.totalPrice * porcentagem / 100);
        }
      }
    }

    return totaisPorParticipante;
  }

  Map<String, List<ArtigoDetalhado>> obterArtigosPorParticipante() {
    final artigosPorParticipante = <String, List<ArtigoDetalhado>>{};

    for (final participante in participantes) {
      artigosPorParticipante[participante.id] = [];
    }

    for (final artigo in artigos) {
      if (artigo.participantePorcentagem.isEmpty) {
        // Dividir igualmente
        final valorPorPessoa = artigo.totalPrice / participantes.length;
        for (final participante in participantes) {
          artigosPorParticipante[participante.id]?.add(
            ArtigoDetalhado(
              nome: artigo.nome,
              valor: valorPorPessoa,
              quantidade: 1 / participantes.length,
            ),
          );
        }
      } else {
        // Dividir de acordo com as porcentagens
        for (final entry in artigo.participantePorcentagem.entries) {
          final participanteId = entry.key;
          final porcentagem = entry.value;
          if (porcentagem > 0) {
            artigosPorParticipante[participanteId]?.add(
              ArtigoDetalhado(
                nome: artigo.nome,
                valor: artigo.totalPrice * porcentagem / 100,
                quantidade: porcentagem / 100,
              ),
            );
          }
        }
      }
    }

    return artigosPorParticipante;
  }
}
