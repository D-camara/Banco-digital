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
  static const TextStyle whiteText = TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

  // Método para as linhas de saldo
  Widget saldoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: whiteText.copyWith(
              fontSize: 15,
              fontWeight:
                  label == 'Saldo:'
                      ? FontWeight.bold
                      : FontWeight.normal, // só "Saldo:" em negrito
            ),
          ),
          Text(value, style: whiteText.copyWith(fontSize: 15)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8A0F16),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 40,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(
              24,
            ), // ajuste o valor para mais ou menos arredondado
          ),
        ),
        title: Text(
          'Bem-vindo, $nome!',
          style: const TextStyle(
            fontSize: 17,
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
          // Container vermelho com altura fixa
          Container(
            height: 200,
            color: const Color(0xFF8A0F16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 13),
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
                                  tilePadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Real (BRL):',
                                        style: whiteText.copyWith(fontSize: 15),
                                      ),
                                      Text(
                                        'R\$ ${saldoBRL.toStringAsFixed(2)}',
                                        style: whiteText.copyWith(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(0),
                                    ),
                                  ),
                                  collapsedShape: RoundedRectangleBorder(
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
          // O preto ocupa todo o espaço restante
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 0, 0, 0),
              width: double.infinity,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 18.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Historico de Transações',
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: const Color(0xFF8A0F16),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Pix recebido de João',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '+ R\$ 150,00',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Divider(color: Colors.white54),
                          Text(
                            'Pagamento cartão',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '- R\$ 80,00',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Divider(color: Colors.white54),
                          Text(
                            'Transferência para Maria',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '- R\$ 200,00',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          SizedBox(height: 12),
                          // Widget de texto adicionado no card de histórico
                          Center(
                            child: Text(
                              'Ver mais',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.bold, // Já está em negrito
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ...adicione mais cards se quiser...
                  const SizedBox(
                    height: 80,
                  ), // Espaço para não ficar atrás da barra inferior
                ],
              ),
            ),
          ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Imagem da esquerda (mais para a esquerda)
                Padding(
                  padding: const EdgeInsets.only(
                    right: 12,
                    top: 8,
                  ), // ajuste o valor de right
                  child: Image.asset('assets/home.png', height: 36, width: 36),
                ),
                // Imagem do meio (mais para a direita)
                GestureDetector(
                  onTap: _abrirTransferencia,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 20,
                    ), // ajuste left/right
                    child: Image.asset(
                      'assets/transf.png',
                      height: 36,
                      width: 36,
                    ),
                  ),
                ),
                // Imagem da direita (mais para a direita)
                GestureDetector(
                  onTap: _abrirCotacao,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      top: 8,
                    ), // ajuste o valor de left
                    child: Image.asset(
                      'assets/cotacao.png',
                      height: 36,
                      width: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
