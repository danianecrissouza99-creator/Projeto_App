import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/custom_widgets.dart';

class Screen2AssignItems extends ConsumerWidget {
  const Screen2AssignItems({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conta = ref.watch(contaProvider);
    final contaNotifier = ref.read(contaProvider.notifier);

    if (conta.artigos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Atribuição de Artigos')),
        body: const Center(child: Text('Nenhum artigo para atribuir')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atribuição de Artigos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atribua cada artigo aos participantes. Deixe em branco para dividir igualmente entre todos.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...conta.artigos.map((artigo) {
              return _ArtigoAtribuicaoCard(
                artigo: artigo,
                conta: conta,
                onAtribuicaoMudada: (novaAtribuicao) {
                  contaNotifier.atualizarAtribuicaoArtigo(artigo.id, novaAtribuicao);
                },
              );
            }),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Voltar',
                    backgroundColor: Colors.grey,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    label: 'Próximo',
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/screen3');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtigoAtribuicaoCard extends StatefulWidget {
  final Artigo artigo;
  final Conta conta;
  final Function(Map<String, double>) onAtribuicaoMudada;

  const _ArtigoAtribuicaoCard({
    required this.artigo,
    required this.conta,
    required this.onAtribuicaoMudada,
  });

  @override
  State<_ArtigoAtribuicaoCard> createState() => _ArtigoAtribuicaoCardState();
}

class _ArtigoAtribuicaoCardState extends State<_ArtigoAtribuicaoCard> {
  late Map<String, double> atribuicao;
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    atribuicao = Map.from(widget.artigo.participantePorcentagem);
    controllers = widget.conta.participantes
        .map((p) => TextEditingController(
              text: atribuicao[p.id]?.toStringAsFixed(1) ?? '',
            ))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _atualizarAtribuicao() {
    final novaAtribuicao = <String, double>{};
    double totalPorcentagem = 0;

    for (int i = 0; i < widget.conta.participantes.length; i++) {
      final valor = double.tryParse(controllers[i].text) ?? 0;
      if (valor > 0) {
        novaAtribuicao[widget.conta.participantes[i].id] = valor;
        totalPorcentagem += valor;
      }
    }

    if (totalPorcentagem > 0 && (totalPorcentagem - 100).abs() > 0.1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total de porcentagem: ${totalPorcentagem.toStringAsFixed(1)}%. Deve ser 100%.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onAtribuicaoMudada(novaAtribuicao);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Atribuição atualizada'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.artigo.nome,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Total: €${widget.artigo.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ...List.generate(widget.conta.participantes.length, (index) {
              final participante = widget.conta.participantes[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        participante.nome,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controllers[index],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Atualizar Atribuição',
              backgroundColor: Colors.green,
              onPressed: _atualizarAtribuicao,
            ),
          ],
        ),
      ),
    );
  }
}
