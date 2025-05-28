import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CotacaoScreen extends StatefulWidget {
  final double saldoBRL;
  final double saldoUSD;
  final double saldoEUR;
  final double saldoBTC;

  const CotacaoScreen({
    Key? key,
    required this.saldoBRL,
    required this.saldoUSD,
    required this.saldoEUR,
    required this.saldoBTC,
  }) : super(key: key);

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

  final List<Map<String, dynamic>> historicoUSD = [];
  final List<Map<String, dynamic>> historicoEUR = [];
  final List<Map<String, dynamic>> historicoBTC = [];

  @override
  void initState() {
    super.initState();
    saldoBRL = widget.saldoBRL;
    saldoUSD = widget.saldoUSD;
    saldoEUR = widget.saldoEUR;
    saldoBTC = widget.saldoBTC;
    fetchCotacao();
  }

  Future<void> fetchCotacao() async {
    final url = Uri.parse('https://api.hgbrasil.com/finance?format=json&key=784a4c53');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final usd = data['results']['currencies']['USD']['buy'] * 1.0;
      final eur = data['results']['currencies']['EUR']['buy'] * 1.0;
      final btc = data['results']['currencies']['BTC']['buy'] * 1.0;
      final now = DateTime.now();
      setState(() {
        cotacao = {
          'USD': usd,
          'EUR': eur,
          'BRL': 1.0,
          'BTC': btc,
        };
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar cotação')),
      );
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
                double pagadoraEmBRL = moedaSelecionada == 'BRL' ? 1.0 : cotacao![moedaSelecionada];
                double alvoEmBRL = moedaAlvo == 'BRL' ? 1.0 : cotacao![moedaAlvo];
                valorRecebido = valorPagador * pagadoraEmBRL / alvoEmBRL;
                resultadoConversao = 'Você receberá ${valorRecebido.toStringAsFixed(moedaAlvo == 'BTC' ? 6 : 2)} $moedaAlvo';
              } else {
                resultadoConversao = '';
                valorRecebido = 0.0;
              }
              setStateDialog(() {});
            }

            return AlertDialog(
              backgroundColor: AppColors.black,
              title: Text('Converter para $moedaAlvo', style: const TextStyle(color: AppColors.red)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: valorController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      labelText: 'Quanto deseja gastar em $moedaSelecionada?',
                      labelStyle: const TextStyle(color: AppColors.gray),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.gray),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.red),
                      ),
                    ),
                    onChanged: (_) => atualizarConversao(),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    dropdownColor: AppColors.black,
                    value: moedaSelecionada,
                    items: moedas
                        .where((m) => m != moedaAlvo)
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m, style: const TextStyle(color: AppColors.white)),
                            ))
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
                    Text(resultadoConversao, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.red)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: AppColors.gray)),
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
                    comprarMoeda(moedaAlvo, moedaSelecionada, valorPagador, valorRecebido);
                  },
                  child: const Text('Converter', style: TextStyle(color: AppColors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void comprarMoeda(String moedaAlvo, String moedaPagadora, double valorPagador, double valorRecebido) {
    if (cotacao == null) return;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo insuficiente')),
      );
      return;
    }

    setState(() {
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conversão realizada!')),
    );
  }

  void finalizarEChecarAtualizacao() {
    Navigator.pop(context, {
      'saldoBRL': saldoBRL,
      'saldoUSD': saldoUSD,
      'saldoEUR': saldoEUR,
      'saldoBTC': saldoBTC,
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
          'saldoBTC': saldoBTC,
        });
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.red),
          title: const Text(
            'COTAÇÃO',
            style: TextStyle(
              color: AppColors.red,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 2,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.red),
              tooltip: 'Salvar e voltar',
              onPressed: finalizarEChecarAtualizacao,
            ),
          ],
        ),
        body: carregando
            ? const Center(child: CircularProgressIndicator(color: AppColors.red))
            : cotacao == null
                ? const Center(
                    child: Text(
                      'Não foi possível obter cotações',
                      style: TextStyle(color: AppColors.white),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40), // <-- padding extra no bottom
                    children: [
                      buildHistoricoList(historicoUSD, 'USD'),
                      buildHistoricoList(historicoEUR, 'EUR'),
                      buildHistoricoList(historicoBTC, 'BTC'),
                      const SizedBox(height: 20),
                      _buildCurrencyCard('USD', cotacao!['USD'], AppColors.red, () => comprarMoedaDialog('USD')),
                      const SizedBox(height: 10),
                      _buildCurrencyCard('EUR', cotacao!['EUR'], AppColors.red, () => comprarMoedaDialog('EUR')),
                      const SizedBox(height: 10),
                      _buildCurrencyCard('BTC', cotacao!['BTC'], AppColors.red, () => comprarMoedaDialog('BTC'), isBTC: true),
                      const SizedBox(height: 10),
                      _buildCurrencyCard('BRL', 1.0, AppColors.white, () => comprarMoedaDialog('BRL')),
                      const SizedBox(height: 30),
                      const Divider(
                        thickness: 1.2,
                        color: AppColors.gray,
                        height: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Seus saldos atualizados:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Real (BRL): R\$ ${saldoBRL.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, color: AppColors.gray)),
                      Text('Dólar (USD): \$ ${saldoUSD.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, color: AppColors.gray)),
                      Text('Euro (EUR): € ${saldoEUR.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, color: AppColors.gray)),
                      Text('Bitcoin (BTC): ${saldoBTC.toStringAsFixed(6)} BTC', style: const TextStyle(fontSize: 15, color: AppColors.gray)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCurrencyCard(String moeda, double valor, Color color, VoidCallback onPressed, {bool isBTC = false}) {
    return Card(
      color: AppColors.black,
      elevation: 4,
      shadowColor: AppColors.red.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // padding menor
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                moeda == 'USD'
                    ? Icons.attach_money
                    : moeda == 'EUR'
                        ? Icons.euro
                        : moeda == 'BTC'
                            ? Icons.currency_bitcoin
                            : Icons.monetization_on,
                color: AppColors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$moeda R\$ ${valor.toStringAsFixed(isBTC ? 0 : 2)}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // padding menor
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
              ),
              onPressed: onPressed,
              child: const Text('COMPRAR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHistoricoList(List<Map<String, dynamic>> historico, String moeda) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4, top: 16),
          child: Text(
            'Histórico $moeda',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.red,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.red.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
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
                  color: AppColors.red,
                  size: 22,
                ),
                title: Text(
                  moeda == 'BTC'
                      ? 'R\$ ${valor.toStringAsFixed(0)}'
                      : 'R\$ ${valor.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: AppColors.gray,
                  ),
                ),
                subtitle: Text(
                  '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')} - ${data.day}/${data.month}',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class AppColors {
  static const Color red = Color(0xFFB5121B);
  static const Color darkRed = Color(0xFF8A0F16);
  static const Color blue = Color(0xFF002856);
  static const Color gray = Color(0xFFEEEEEE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}