import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CotacaoScreen extends StatefulWidget {
  final double saldoBRL;
  final double saldoUSD;
  final double saldoEUR;
  final double saldoBTC; // Novo parâmetro

  const CotacaoScreen({
    super.key,
    required this.saldoBRL,
    required this.saldoUSD,
    required this.saldoEUR,
    required this.saldoBTC, // Novo parâmetro
  });

  @override
  State<CotacaoScreen> createState() => _CotacaoScreenState();
}

class _CotacaoScreenState extends State<CotacaoScreen> {
  Map<String, dynamic>? cotacao;
  bool carregando = true;

  late double saldoBRL;
  late double saldoUSD;
  late double saldoEUR;
  late double saldoBTC;

  // Histórico com data/hora
  final List<Map<String, dynamic>> historicoUSD = [];
  final List<Map<String, dynamic>> historicoEUR = [];
  final List<Map<String, dynamic>> historicoBTC = []; // Histórico BTC

  @override
  void initState() {
    super.initState();
    saldoBRL = widget.saldoBRL;
    saldoUSD = widget.saldoUSD;
    saldoEUR = widget.saldoEUR;
    saldoBTC = widget.saldoBTC; // Inicializa com valor recebido
    fetchCotacao();
  }

  Future<void> fetchCotacao() async {
    // Substitua 'sua_chave_aqui' pela sua chave da HG Brasil
    final url = Uri.parse(
      'https://api.hgbrasil.com/finance?format=json&key=784a4c53',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final usd = data['results']['currencies']['USD']['buy'] * 1.0;
      final eur = data['results']['currencies']['EUR']['buy'] * 1.0;
      final btc = data['results']['currencies']['BTC']['buy'] * 1.0;
      final now = DateTime.now();
      setState(() {
        cotacao = {'USD': usd, 'EUR': eur, 'BRL': 1.0, 'BTC': btc};
        historicoUSD.add({'valor': usd, 'data': now});
        if (historicoUSD.length > 10) historicoUSD.removeAt(0);
        historicoEUR.add({'valor': eur, 'data': now});
        if (historicoEUR.length > 10) historicoEUR.removeAt(0);
        historicoBTC.add({'valor': btc, 'data': now});
        if (historicoBTC.length > 10) historicoBTC.removeAt(0);
        carregando = false;
      });
    } else {
      setState(() {
        carregando = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao carregar cotação')));
    }
  }

  void comprarMoedaDialog(String moedaAlvo) async {
    if (cotacao == null) return;
    final moedas = ['BRL', 'USD', 'EUR', 'BTC'];
    String moedaSelecionada = moedas.firstWhere((m) => m != moedaAlvo);
    double valorPagador = 0.0;
    double valorRecebido = 0.0;
    final TextEditingController valorController = TextEditingController();
    String resultadoConversao = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void atualizarConversao() {
              valorPagador = double.tryParse(valorController.text) ?? 0.0;
              if (valorPagador > 0) {
                // Conversão: quanto da moeda alvo recebo gastando valorPagador da moeda pagadora
                double pagadoraEmBRL =
                    moedaSelecionada == 'BRL'
                        ? 1.0
                        : cotacao![moedaSelecionada];
                double alvoEmBRL =
                    moedaAlvo == 'BRL' ? 1.0 : cotacao![moedaAlvo];
                valorRecebido = valorPagador * pagadoraEmBRL / alvoEmBRL;
                resultadoConversao =
                    'Você receberá ${valorRecebido.toStringAsFixed(moedaAlvo == 'BTC' ? 6 : 2)} $moedaAlvo';
              } else {
                resultadoConversao = '';
                valorRecebido = 0.0;
              }
              setStateDialog(() {});
            }

            return AlertDialog(
              title: Text('Converter para $moedaAlvo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: valorController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Quanto deseja gastar em $moedaSelecionada?',
                    ),
                    onChanged: (_) => atualizarConversao(),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: moedaSelecionada,
                    items:
                        moedas
                            .where((m) => m != moedaAlvo)
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        moedaSelecionada = value;
                        atualizarConversao();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  if (resultadoConversao.isNotEmpty)
                    Text(
                      resultadoConversao,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    valorPagador = double.tryParse(valorController.text) ?? 0.0;
                    if (valorPagador <= 0 || valorRecebido <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Valor inválido')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    comprarMoeda(
                      moedaAlvo,
                      moedaSelecionada,
                      valorPagador,
                      valorRecebido,
                    );
                  },
                  child: const Text('Converter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Novo método: valorPagador é quanto desconta da moedaPagadora, valorRecebido é quanto credita na moedaAlvo
  void comprarMoeda(
    String moedaAlvo,
    String moedaPagadora,
    double valorPagador,
    double valorRecebido,
  ) {
    if (cotacao == null) return;

    // Verifica saldo suficiente na moeda pagadora
    bool saldoSuficiente = false;
    switch (moedaPagadora) {
      case 'BRL':
        saldoSuficiente = saldoBRL >= valorPagador;
        break;
      case 'USD':
        saldoSuficiente = saldoUSD >= valorPagador;
        break;
      case 'EUR':
        saldoSuficiente = saldoEUR >= valorPagador;
        break;
      case 'BTC':
        saldoSuficiente = saldoBTC >= valorPagador;
        break;
    }

    if (!saldoSuficiente) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saldo insuficiente')));
      return;
    }

    setState(() {
      // Debita da moeda pagadora
      switch (moedaPagadora) {
        case 'BRL':
          saldoBRL -= valorPagador;
          break;
        case 'USD':
          saldoUSD -= valorPagador;
          break;
        case 'EUR':
          saldoEUR -= valorPagador;
          break;
        case 'BTC':
          saldoBTC -= valorPagador;
          break;
      }
      // Credita na moeda alvo
      switch (moedaAlvo) {
        case 'BRL':
          saldoBRL += valorRecebido;
          break;
        case 'USD':
          saldoUSD += valorRecebido;
          break;
        case 'EUR':
          saldoEUR += valorRecebido;
          break;
        case 'BTC':
          saldoBTC += valorRecebido;
          break;
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Conversão realizada!')));
  }

  Widget buildHistoricoList(
    List<Map<String, dynamic>> historico,
    String moeda,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico $moeda',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historico.length,
          itemBuilder: (context, index) {
            final item = historico[historico.length - 1 - index];
            final valor = item['valor'] as double;
            final data = item['data'] as DateTime;
            return ListTile(
              dense: true,
              leading: Icon(
                Icons.trending_up,
                color:
                    moeda == 'USD'
                        ? Colors.blue
                        : moeda == 'EUR'
                        ? Colors.green
                        : Colors.orange,
              ),
              title: Text(
                moeda == 'BTC'
                    ? 'R\$ ${valor.toStringAsFixed(0)}'
                    : 'R\$ ${valor.toStringAsFixed(2)}',
              ),
              subtitle: Text(
                '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')} - ${data.day}/${data.month}',
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void finalizarEChecarAtualizacao() {
    Navigator.pop(context, {
      'saldoBRL': saldoBRL,
      'saldoUSD': saldoUSD,
      'saldoEUR': saldoEUR,
      'saldoBTC': saldoBTC, // Retorna saldoBTC
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {
          'saldoBRL': saldoBRL,
          'saldoUSD': saldoUSD,
          'saldoEUR': saldoEUR,
          'saldoBTC': saldoBTC, // Retorna saldoBTC
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cotação'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Salvar e voltar',
              onPressed: finalizarEChecarAtualizacao,
            ),
          ],
        ),
        body:
            carregando
                ? const Center(child: CircularProgressIndicator())
                : cotacao == null
                ? const Center(child: Text('Não foi possível obter cotações'))
                : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    buildHistoricoList(historicoUSD, 'USD'),
                    buildHistoricoList(historicoEUR, 'EUR'),
                    buildHistoricoList(historicoBTC, 'BTC'),
                    const SizedBox(height: 20),
                    ListTile(
                      title: const Text('USD'),
                      trailing: Text(
                        'R\$ ${cotacao!['USD'].toStringAsFixed(2)}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => comprarMoedaDialog('USD'),
                      child: const Text('Comprar Dólar'),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: const Text('EUR'),
                      trailing: Text(
                        'R\$ ${cotacao!['EUR'].toStringAsFixed(2)}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => comprarMoedaDialog('EUR'),
                      child: const Text('Comprar Euro'),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: const Text('BTC'),
                      trailing: Text(
                        'R\$ ${cotacao!['BTC'].toStringAsFixed(0)}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => comprarMoedaDialog('BTC'),
                      child: const Text('Comprar Bitcoin'),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: const Text('BRL'),
                      trailing: const Text('R\$ 1.00'),
                    ),
                    ElevatedButton(
                      onPressed: () => comprarMoedaDialog('BRL'),
                      child: const Text('Comprar Real'),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const Text(
                      'Seus saldos atualizados:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Real (BRL): R\$ ${saldoBRL.toStringAsFixed(2)}'),
                    Text('Dólar (USD): \$ ${saldoUSD.toStringAsFixed(2)}'),
                    Text('Euro (EUR): € ${saldoEUR.toStringAsFixed(2)}'),
                    Text('Bitcoin (BTC): ${saldoBTC.toStringAsFixed(6)} BTC'),
                  ],
                ),
      ),
    );
  }
}
