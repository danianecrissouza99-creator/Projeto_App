import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'package:uuid/uuid.dart';

final contaProvider = NotifierProvider<ContaNotifier, Conta>(() {
  return ContaNotifier();
});

class ContaNotifier extends Notifier<Conta> {
  @override
  Conta build() {
    return Conta(
      participantes: [],
      artigos: [],
    );
  }

  void adicionarParticipante(String nome) {
    if (nome.trim().isEmpty) return;
    final novoParticipante = Participante(
      id: const Uuid().v4(),
      nome: nome.trim(),
    );
    state = state.copyWith(
      participantes: [...state.participantes, novoParticipante],
    );
  }

  void removerParticipante(String id) {
    state = state.copyWith(
      participantes:
          state.participantes.where((p) => p.id != id).toList(),
    );
  }

  void adicionarArtigo(String nome, double preco, double quantidade) {
    if (nome.trim().isEmpty || preco <= 0 || quantidade <= 0) return;
    final novoArtigo = Artigo(
      id: const Uuid().v4(),
      nome: nome.trim(),
      preco: preco,
      quantidade: quantidade,
    );
    state = state.copyWith(
      artigos: [...state.artigos, novoArtigo],
    );
  }

  void removerArtigo(String id) {
    state = state.copyWith(
      artigos: state.artigos.where((a) => a.id != id).toList(),
    );
  }

  void atualizarAtribuicaoArtigo(
      String artigoId, Map<String, double> novaAtribuicao) {
    final artigoIndex =
        state.artigos.indexWhere((a) => a.id == artigoId);
    if (artigoIndex == -1) return;

    final artigoAtualizado =
        state.artigos[artigoIndex].copyWith(participantePorcentagem: novaAtribuicao);
    final novosArtigos = [...state.artigos];
    novosArtigos[artigoIndex] = artigoAtualizado;

    state = state.copyWith(artigos: novosArtigos);
  }

  void limpar() {
    state = Conta(
      participantes: [],
      artigos: [],
    );
  }
}
