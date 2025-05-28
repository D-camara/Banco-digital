import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  late double saldoBTC;
  late String nome;
  String mensagem = '';
  File? _imagemCamera;

  final Map<String, String> _moedaNomes = {
    'BRL': 'Real (BRL)',
    'USD': 'Dólar (USD)',
    'EUR': 'Euro (EUR)',
    'BTC': 'Bitcoin (BTC)',
  };

  double get saldoAtual {
    switch (moedaSelecionada) {
      case 'BRL':
        return saldoBRL;
      case 'USD':
        return saldoUSD;
      case 'EUR':
        return saldoEUR;
      case 'BTC':
        return saldoBTC;
      default:
        return 0.0;
    }
  }

  String get simboloMoeda {
    switch (moedaSelecionada) {
      case 'BRL':
        return 'R\$';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'BTC':
        return '₿';
      default:
        return '';
    }
  }

  Future<void> _selecionarMoeda() async {
    final selecionada = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _moedaNomes.entries.map((entry) {
            return ListTile(
              leading: Icon(
                entry.key == 'BRL'
                    ? Icons.attach_money
                    : entry.key == 'USD'
                        ? Icons.money
                        : entry.key == 'EUR'
                            ? Icons.euro
                            : Icons.currency_bitcoin,
              ),
              title: Text(entry.value),
              onTap: () => Navigator.pop(context, entry.key),
            );
          }).toList(),
        ),
      ),
    );
    if (selecionada != null && selecionada != moedaSelecionada) {
      setState(() {
        moedaSelecionada = selecionada;
      });
    }
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
      case 'BTC':
        saldoSuficiente = saldoBTC >= valor;
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
        case 'BTC':
          saldoBTC -= valor;
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
        'saldoBTC': saldoBTC, // Retorna BTC
      });
    });
  }

  Future<void> _abrirCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagemCamera = File(pickedFile.path);
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
    saldoBTC = args['saldoBTC'] ?? 1.0; // Inicializa BTC
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferência'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Olá $nome, faça uma transferência:'),
                      const SizedBox(height: 20),
                      Text('Selecione a moeda para transferir:'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _selecionarMoeda,
                        icon: Icon(
                          moedaSelecionada == 'BRL'
                              ? Icons.attach_money
                              : moedaSelecionada == 'USD'
                                  ? Icons.money
                                  : moedaSelecionada == 'EUR'
                                      ? Icons.euro
                                      : Icons.currency_bitcoin,
                        ),
                        label: Text(_moedaNomes[moedaSelecionada]!),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Saldo disponível: $simboloMoeda ${moedaSelecionada == 'BTC' ? saldoAtual.toStringAsFixed(6) : saldoAtual.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _destinatarioController,
                        decoration: const InputDecoration(labelText: 'Destinatário'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _valorController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Valor (${_moedaNomes[moedaSelecionada]})',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _transferir,
                        child: const Text('Transferir'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _abrirCamera,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Abrir Câmera'),
                      ),
                      if (_imagemCamera != null) ...[
                        const SizedBox(height: 10),
                        Image.file(_imagemCamera!, height: 120),
                      ],
                      if (mensagem.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(mensagem, style: TextStyle(color: Colors.green)),
                        ElevatedButton(
                          onPressed: () {
                            Share.share(mensagem);
                          },
                          child: const Text('Compartilhar comprovante'),
                        ),
                      ],
                      const Spacer(),
                      const Divider(),
                      Text(
                        'Saldos totais:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('BRL: R\$ ${saldoBRL.toStringAsFixed(2)}'),
                      Text('USD: \$ ${saldoUSD.toStringAsFixed(2)}'),
                      Text('EUR: € ${saldoEUR.toStringAsFixed(2)}'),
                      Text('BTC: ${saldoBTC.toStringAsFixed(6)}'),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}