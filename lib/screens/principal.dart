import 'package:flutter/material.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({Key? key}) : super(key: key);

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  late double saldoBRL;
  late double saldoUSD;
  late double saldoEUR;
  late String nome;

  @override
  void initState() {
    super.initState();
    saldoBRL = 1500.00;
    saldoUSD = 200.00;
    saldoEUR = 100.00;
    nome = 'Usuário';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    nome = args['nome'] ?? nome;
    if (args['saldoBRL'] != null) saldoBRL = args['saldoBRL'];
    if (args['saldoUSD'] != null) saldoUSD = args['saldoUSD'];
    if (args['saldoEUR'] != null) saldoEUR = args['saldoEUR'];
  }

  Future<void> _abrirCotacao() async {
    final result = await Navigator.pushNamed(
      context,
      '/cotacao',
      arguments: {
        'saldoBRL': saldoBRL,
        'saldoUSD': saldoUSD,
        'saldoEUR': saldoEUR,
      },
    );
    if (result is Map) {
      setState(() {
        saldoBRL = result['saldoBRL'] ?? saldoBRL;
        saldoUSD = result['saldoUSD'] ?? saldoUSD;
        saldoEUR = result['saldoEUR'] ?? saldoEUR;
      });
    }
  }

  Future<void> _abrirTransferencia() async {
    final result = await Navigator.pushNamed(
      context,
      '/transferencia',
      arguments: {
        'nome': nome,
        'saldoBRL': saldoBRL,
        'saldoUSD': saldoUSD,
        'saldoEUR': saldoEUR,
      },
    );
    if (result is Map) {
      setState(() {
        saldoBRL = result['saldoBRL'] ?? saldoBRL;
        saldoUSD = result['saldoUSD'] ?? saldoUSD;
        saldoEUR = result['saldoEUR'] ?? saldoEUR;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banco Digital')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Bem-vindo, $nome!', style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Saldos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Real (BRL):'),
                        Text('R\$ ${saldoBRL.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Dólar (USD):'),
                        Text('\$ ${saldoUSD.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Euro (EUR):'),
                        Text('€ ${saldoEUR.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _abrirCotacao,
              child: const Text('Ver Cotação'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _abrirTransferencia,
              child: const Text('Transferência'),
            ),
          ],
        ),
      ),
    );
  }
}