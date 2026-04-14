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