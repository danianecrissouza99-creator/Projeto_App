import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/custom_widgets.dart';

class Screen1ParticipantsItems extends ConsumerWidget {
  const Screen1ParticipantsItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conta = ref.watch(contaProvider);
    final contaNotifier = ref.read(contaProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Divisão de Contas'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ParticipantsSection(
              conta: conta,
              onAdd: (nome) => contaNotifier.adicionarParticipante(nome),
              onRemove: (id) => contaNotifier.removerParticipante(id),
            ),
            const SizedBox(height: 24),
            _ItemsSection(
              conta: conta,
              onAdd: (nome, preco, quantidade) =>
                  contaNotifier.adicionarArtigo(nome, preco, quantidade),
              onRemove: (id) => contaNotifier.removerArtigo(id),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Próximo',
              backgroundColor: Colors.blue,
              onPressed: () {
                // Só permite avançar quando os dados mínimos da conta foram preenchidos.
                if (!conta.isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'A conta deve ter pelo menos 2 participantes e 1 artigo com valores positivos.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.of(context).pushNamed('/screen2');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantsSection extends StatefulWidget {
  final Conta conta;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const _ParticipantsSection({
    required this.conta,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_ParticipantsSection> createState() => _ParticipantsSectionState();
}

class _ParticipantsSectionState extends State<_ParticipantsSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Participantes'),
        CustomTextField(
          label: 'Nome do Participante',
          hint: 'Ex: João',
          controller: _controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo obrigatório';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        CustomButton(
          label: 'Adicionar Participante',
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onAdd(_controller.text);
              _controller.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Participante adicionado com sucesso'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        // Mostra estado vazio até existir pelo menos um participante.
        if (widget.conta.participantes.isEmpty)
          const EmptyStateWidget(
            message: 'Nenhum participante adicionado ainda',
            icon: Icons.person_outline,
          )
        else
          Column(
            children: widget.conta.participantes
                .map(
                  (p) => ParticipanteCard(
                    nome: p.nome,
                    onDelete: () => widget.onRemove(p.id),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _ItemsSection extends StatefulWidget {
  final Conta conta;
  final Function(String, double, double) onAdd;
  final Function(String) onRemove;

  const _ItemsSection({
    required this.conta,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_ItemsSection> createState() => _ItemsSectionState();
}

class _ItemsSectionState extends State<_ItemsSection> {
  late TextEditingController _nomeController;
  late TextEditingController _precoController;
  late TextEditingController _quantidadeController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _precoController = TextEditingController();
    _quantidadeController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void _adicionarArtigo() {
    // Validação em etapas para dar feedback específico ao usuário.
    if (_nomeController.text.trim().isEmpty) {
      _showError('Nome do artigo é obrigatório');
      return;
    }

    final preco = double.tryParse(_precoController.text);
    if (preco == null || preco <= 0) {
      _showError('Preço deve ser um valor positivo');
      return;
    }

    final quantidade = double.tryParse(_quantidadeController.text);
    if (quantidade == null || quantidade <= 0) {
      _showError('Quantidade deve ser um valor positivo');
      return;
    }

    widget.onAdd(_nomeController.text, preco, quantidade);
    _nomeController.clear();
    _precoController.clear();
    _quantidadeController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Artigo adicionado com sucesso'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Artigos'),
        CustomTextField(
          label: 'Nome do Artigo',
          hint: 'Ex: Pizza Margherita',
          controller: _nomeController,
        ),
        CustomTextField(
          label: 'Preço (€)',
          hint: '0.00',
          controller: _precoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        CustomTextField(
          label: 'Quantidade',
          hint: '1',
          controller: _quantidadeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        CustomButton(label: 'Adicionar Artigo', onPressed: _adicionarArtigo),
        const SizedBox(height: 16),
        // Mostra estado vazio até existir pelo menos um artigo.
        if (widget.conta.artigos.isEmpty)
          const EmptyStateWidget(
            message: 'Nenhum artigo adicionado ainda',
            icon: Icons.shopping_cart_outlined,
          )
        else
          Column(
            children: widget.conta.artigos
                .map(
                  (a) => ArtigoCard(
                    nome: a.nome,
                    preco: a.preco,
                    quantidade: a.quantidade,
                    total: a.totalPrice,
                    onDelete: () => widget.onRemove(a.id),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
