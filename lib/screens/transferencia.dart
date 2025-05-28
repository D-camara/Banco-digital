import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class TransferenciaScreen extends StatefulWidget {
  final Map<String, dynamic>? args;
  const TransferenciaScreen({Key? key, this.args}) : super(key: key);

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _destinatarioController = TextEditingController();

  String moedaSelecionada = 'BRL';
  late double saldoBRL;
  late double saldoUSD;
  late double saldoEUR;
  late String nome;
  String mensagem = '';

  // Adicione esta função para abrir o scanner em um Dialog
  Future<void> _abrirQRScanner() async {
    String? resultado;
    await showDialog(
      context: context,
      builder: (context) {
        final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
        QRViewController? controller;

        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 300,
            height: 300,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (ctrl) {
                controller = ctrl;
                ctrl.scannedDataStream.listen((scanData) {
                  controller?.pauseCamera();
                  Navigator.of(context).pop(scanData.code);
                });
              },
            ),
          ),
        );
      },
    ).then((value) {
      resultado = value;
    });

    if (resultado != null) {
      setState(() {
        _destinatarioController.text = resultado!;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final args = widget.args ?? {};
    nome = args['nome'] ?? 'Usuário';
    saldoBRL = args['saldoBRL'] ?? 1500.0;
    saldoUSD = args['saldoUSD'] ?? 200.0;
    saldoEUR = args['saldoEUR'] ?? 100.0;
  }

  void _transferir() {
    double valor = double.tryParse(_valorController.text) ?? 0.0;
    if (valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor inválido')),
      );
      return;
    }
    bool saldoSuficiente = false;
    switch (moedaSelecionada) {
      case 'BRL':
        saldoSuficiente = saldoBRL >= valor;
        break;
      case 'USD':
        saldoSuficiente = saldoUSD >= valor;
        break;
      case 'EUR':
        saldoSuficiente = saldoEUR >= valor;
        break;
    }
    if (!saldoSuficiente) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo insuficiente')),
      );
      return;
    }
    setState(() {
      switch (moedaSelecionada) {
        case 'BRL':
          saldoBRL -= valor;
          break;
        case 'USD':
          saldoUSD -= valor;
          break;
        case 'EUR':
          saldoEUR -= valor;
          break;
      }
      mensagem = 'Transferência de $valor $moedaSelecionada realizada!';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
    // Retorna os saldos atualizados para a tela principal
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context, {
        'saldoBRL': saldoBRL,
        'saldoUSD': saldoUSD,
        'saldoEUR': saldoEUR,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferência'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Olá $nome, faça uma transferência:'),
            const SizedBox(height: 20),
            Text('Saldo disponível:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('BRL: R\$ ${saldoBRL.toStringAsFixed(2)}'),
                Text('USD: \$ ${saldoUSD.toStringAsFixed(2)}'),
                Text('EUR: € ${saldoEUR.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _destinatarioController,
              decoration: const InputDecoration(labelText: 'Destinatário'),
            ),
            const SizedBox(height: 10),
            // Adicione o botão logo abaixo do campo destinatário
            ElevatedButton.icon(
              onPressed: _abrirQRScanner,
              icon: Icon(Icons.qr_code_scanner),
              label: Text('Ler QR code'),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: moedaSelecionada,
              items: const [
                DropdownMenuItem(value: 'BRL', child: Text('Real (BRL)')),
                DropdownMenuItem(value: 'USD', child: Text('Dólar (USD)')),
                DropdownMenuItem(value: 'EUR', child: Text('Euro (EUR)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    moedaSelecionada = value;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valor'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _transferir,
              child: const Text('Transferir'),
            ),
            if (mensagem.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(mensagem, style: TextStyle(color: Colors.green)),
              ElevatedButton(
                onPressed: () {
                  Share.share(mensagem);
                },
                child: Text('Compartilhar comprovante'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}