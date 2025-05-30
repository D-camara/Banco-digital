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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 70,
        title: Text(
          'Bem-vindo, $nome!',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset("assets/icon.png", height: 40, width: 40),
          ),
        ],
      ),
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
                          const SizedBox(height: 0),
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
                                        Text('Real (BRL):', style: whiteText),
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
                      // Removido o Positioned com a imagem sobreposta
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        child: Card(
          color: const Color(0xFF8A0F16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Alinha uniformemente
              children: [
                Image.asset('assets/home.png', height: 26, width: 36),
                GestureDetector(
                  onTap: _abrirTransferencia,
                  child: Image.asset(
                    'assets/transf.png',
                    height: 36,
                    width: 36,
                  ),
                ),
                GestureDetector(
                  onTap: _abrirCotacao,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.asset(
                      'assets/cotacao.png',
                      height: 36,
                      width: 46,
                    ),
                  ),
                ),
                Image.asset('assets/cart.png', height: 36, width: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
