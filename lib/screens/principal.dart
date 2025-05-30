import 'package:flutter/material.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  late double saldoBRL;
  late double saldoUSD;
  late double saldoEUR;
  late double saldoBTC;
  late String nome;

  @override
  void initState() {
    super.initState();
    saldoBRL = 1500.00;
    saldoUSD = 200.00;
    saldoEUR = 100.00;
    saldoBTC = 1.0;
    nome = 'Usuário';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
        {};
    nome = args['nome'] ?? nome;
    saldoBRL = args['saldoBRL'] ?? saldoBRL;
    saldoUSD = args['saldoUSD'] ?? saldoUSD;
    saldoEUR = args['saldoEUR'] ?? saldoEUR;
    saldoBTC = args['saldoBTC'] ?? saldoBTC;
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

  // Estilo padrão para textos brancos
  static const TextStyle whiteText = TextStyle(color: Colors.white);

  // Método para as linhas de saldo
  Widget saldoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: whiteText),
          Text(value, style: whiteText),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle botaoPreto = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF8A0F16),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFF8A0F16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 0,
                ),
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 46),
                          const SizedBox(height: 0),
                          // Texto fora do Card
                          Text(
                            'Bem-vindo, $nome!',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 80),
                          Card(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  saldoRow('Saldo:', ''),
                                  ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Real (BRL):',
                                          style: whiteText,
                                        ),
                                        Text(
                                          'R\$ ${saldoBRL.toStringAsFixed(2)}',
                                          style: whiteText,
                                        ),
                                      ],
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      side: BorderSide.none,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(0),
                                      ),
                                    ),
                                    collapsedShape:
                                        const RoundedRectangleBorder(
                                          side: BorderSide.none,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(0),
                                          ),
                                        ),
                                    children: [
                                      saldoRow(
                                        'Dólar (USD):',
                                        '\$ ${saldoUSD.toStringAsFixed(2)}',
                                      ),
                                      saldoRow(
                                        'Euro (EUR):',
                                        '€ ${saldoEUR.toStringAsFixed(2)}',
                                      ),
                                      saldoRow(
                                        'Bitcoin (BTC):',
                                        '${saldoBTC.toStringAsFixed(6)} BTC',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Imagem sobreposta no canto superior direito
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Image.asset(
                          "assets/icon.png",
                          height: 120,
                          width: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Novo container para dividir a tela em duas partes
          Expanded(child: Container(color: const Color.fromARGB(255, 0, 0, 0))),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Card(
          color: Colors.white.withOpacity(0.08),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botão de Cotação com imagem
                GestureDetector(
                  onTap: _abrirCotacao,
                  child: Image.asset(
                    'assets/cotacao.png',
                    height: 36,
                    width: 36,
                  ),
                ),
                // Botão de Transferência com imagem
                GestureDetector(
                  onTap: _abrirTransferencia,
                  child: Image.asset('assets/cart.png', height: 40, width: 36),
                ),
                // Nova imagem adicionada
                Image.asset('assets/home.png', height: 26, width: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
