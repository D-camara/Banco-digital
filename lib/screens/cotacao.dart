import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CotacaoScreen extends StatefulWidget {
  final double saldoBRL;
  final double saldoUSD;
  final double saldoEUR;

  const CotacaoScreen({
    Key? key,
    required this.saldoBRL,
    required this.saldoUSD,
    required this.saldoEUR,
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

  // Simulação de histórico para o gráfico
  final List<double> historicoUSD = [5.0, 5.1, 5.2, 5.15, 5.18, 5.22, 5.20];
  final List<double> historicoEUR = [5.4, 5.35, 5.38, 5.36, 5.40, 5.42, 5.39];

  @override
  void initState() {
    super.initState();
    saldoBRL = widget.saldoBRL;
    saldoUSD = widget.saldoUSD;
    saldoEUR = widget.saldoEUR;
    fetchCotacao();
  }

  Future<void> fetchCotacao() async {
    final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/BRL');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        cotacao = json.decode(response.body)['rates'];
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
    final moedas = ['BRL', 'USD', 'EUR'];
    String moedaSelecionada = moedas.firstWhere((m) => m != moedaAlvo);
    double valorCompra = 0.0;
    final TextEditingController valorController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Comprar $moedaAlvo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: valorController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Quanto deseja comprar?'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: moedaSelecionada,
                    items: moedas
                        .where((m) => m != moedaAlvo)
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() {
                          moedaSelecionada = value;
                        });
                      }
                    },
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
                    valorCompra = double.tryParse(valorController.text) ?? 0.0;
                    if (valorCompra <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Valor inválido')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    comprarMoeda(moedaAlvo, moedaSelecionada, valorCompra);
                  },
                  child: const Text('Comprar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void comprarMoeda(String moedaAlvo, String moedaPagadora, double valorCompra) {
    if (cotacao == null) return;

    // Conversão de BRL para outras moedas e vice-versa
    double taxaAlvo = moedaAlvo == 'BRL' ? 1.0 : (1 / cotacao![moedaAlvo]);
    double taxaPagadora = moedaPagadora == 'BRL' ? 1.0 : (1 / cotacao![moedaPagadora]);
    double valorEmBRL = valorCompra * taxaAlvo;
    double valorPagador = valorEmBRL / taxaPagadora;

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
      }
      switch (moedaAlvo) {
        case 'BRL':
          saldoBRL += valorCompra;
          break;
        case 'USD':
          saldoUSD += valorCompra;
          break;
        case 'EUR':
          saldoEUR += valorCompra;
          break;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compra de $valorCompra $moedaAlvo realizada!')),
    );
  }

  Widget buildGrafico(List<double> dados, Color cor) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _LineChartPainter(dados, cor),
        child: Container(),
      ),
    );
  }

  void finalizarEChecarAtualizacao() {
    Navigator.pop(context, {
      'saldoBRL': saldoBRL,
      'saldoUSD': saldoUSD,
      'saldoEUR': saldoEUR,
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
        body: carregando
            ? const Center(child: CircularProgressIndicator())
            : cotacao == null
                ? const Center(child: Text('Não foi possível obter cotações'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text('Gráfico USD (simulado)', style: TextStyle(fontWeight: FontWeight.bold)),
                      buildGrafico(historicoUSD, Colors.blue),
                      const SizedBox(height: 10),
                      const Text('Gráfico EUR (simulado)', style: TextStyle(fontWeight: FontWeight.bold)),
                      buildGrafico(historicoEUR, Colors.green),
                      const SizedBox(height: 20),
                      ListTile(
                        title: const Text('USD'),
                        trailing: Text('R\$ ${(1 / cotacao!['USD']).toStringAsFixed(2)}'),
                      ),
                      ElevatedButton(
                        onPressed: () => comprarMoedaDialog('USD'),
                        child: const Text('Comprar Dólar'),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: const Text('EUR'),
                        trailing: Text('R\$ ${(1 / cotacao!['EUR']).toStringAsFixed(2)}'),
                      ),
                      ElevatedButton(
                        onPressed: () => comprarMoedaDialog('EUR'),
                        child: const Text('Comprar Euro'),
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
                      const Text('Seus saldos atualizados:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Real (BRL): R\$ ${saldoBRL.toStringAsFixed(2)}'),
                      Text('Dólar (USD): \$ ${saldoUSD.toStringAsFixed(2)}'),
                      Text('Euro (EUR): € ${saldoEUR.toStringAsFixed(2)}'),
                    ],
                  ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _LineChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double minY = data.reduce((a, b) => a < b ? a : b);
    final double maxY = data.reduce((a, b) => a > b ? a : b);
    final double range = maxY - minY == 0 ? 1 : maxY - minY;

    final double dx = size.width / (data.length - 1);
    final double height = size.height;

    Path path = Path();
    for (int i = 0; i < data.length; i++) {
      double x = i * dx;
      double y = height - ((data[i] - minY) / range * height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Eixos (opcional)
    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, height), Offset(size.width, height), axisPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, height), axisPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}