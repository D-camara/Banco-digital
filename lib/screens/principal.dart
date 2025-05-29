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
  late double saldoBTC; // Novo saldo BTC
  late String nome;

  @override
  void initState() {
    super.initState();
    saldoBRL = 1500.00;
    saldoUSD = 200.00;
    saldoEUR = 100.00;
    saldoBTC = 1.0; // Inicializa com 1 BTC
    nome = 'Usuário';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
        {};
    nome = args['nome'] ?? nome;
    if (args['saldoBRL'] != null) saldoBRL = args['saldoBRL'];
    if (args['saldoUSD'] != null) saldoUSD = args['saldoUSD'];
    if (args['saldoEUR'] != null) saldoEUR = args['saldoEUR'];
    if (args['saldoBTC'] != null) saldoBTC = args['saldoBTC'];
  }

  Future<void> _abrirCotacao() async {
    final result = await Navigator.pushNamed(
      context,
      '/cotacao',
      arguments: {
        'saldoBRL': saldoBRL,
        'saldoUSD': saldoUSD,
        'saldoEUR': saldoEUR,
        'saldoBTC': saldoBTC,
      },
    );
    if (result is Map) {
      setState(() {
        saldoBRL = result['saldoBRL'] ?? saldoBRL;
        saldoUSD = result['saldoUSD'] ?? saldoUSD;
        saldoEUR = result['saldoEUR'] ?? saldoEUR;
        saldoBTC = result['saldoBTC'] ?? saldoBTC;
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
        'saldoBTC': saldoBTC,
      },
    );
    if (result is Map) {
      setState(() {
        saldoBRL = result['saldoBRL'] ?? saldoBRL;
        saldoUSD = result['saldoUSD'] ?? saldoUSD;
        saldoEUR = result['saldoEUR'] ?? saldoEUR;
        saldoBTC = result['saldoBTC'] ?? saldoBTC;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banco Digital')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFF8A0F16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Bem-vindo, $nome!',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 4),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Linha do "Saldo:" alinhada igual às moedas
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Saldo:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Opacity(
                                      opacity: 0,
                                      child: Text(
                                        'R\$ ${saldoBRL.toStringAsFixed(2)}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 0),
                              ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Real (BRL):'),
                                    Text('R\$ ${saldoBRL.toStringAsFixed(2)}'),
                                  ],
                                ),
                                shape: const RoundedRectangleBorder(
                                  side: BorderSide.none,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(0),
                                  ),
                                ),
                                collapsedShape: const RoundedRectangleBorder(
                                  side: BorderSide.none,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(0),
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Dólar (USD):'),
                                        Text(
                                          '\$ ${saldoUSD.toStringAsFixed(2)}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Euro (EUR):'),
                                        Text(
                                          '€ ${saldoEUR.toStringAsFixed(2)}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Bitcoin (BTC):'),
                                        Text(
                                          '${saldoBTC.toStringAsFixed(6)} BTC',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF000000), // Cor da metade inferior
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF000000),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _abrirCotacao,
                child: const Text(
                  'Ver Cotação',
                  style: TextStyle(
                    color: Colors.red, 
                    fontWeight: FontWeight.bold, 
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _abrirTransferencia,
                child: const Text(
                'Transferência',
                style: TextStyle(
                    color: Colors.red, 
                    fontWeight: FontWeight.bold, 
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
