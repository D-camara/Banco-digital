import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart'; // ADICIONADO para inputFormatters

class AppColors {
  static const Color darkRed = Color(0xFF8A0F16);
}

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
  List<Map<String, dynamic>> historico = [];
  String tipoChavePix = 'CPF'; // Novo: tipo de chave Pix

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
      backgroundColor: Colors.black,
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
                color: AppColors.darkRed,
              ),
              title: Text(
                entry.value,
                style: const TextStyle(color: Colors.white),
              ),
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

  String? validarDestinatario(String valor) {
    if (valor.isEmpty) return 'Informe o destinatário';
    if (tipoChavePix == 'CPF') {
      if (!RegExp(r'^\d{11}$').hasMatch(valor)) return 'CPF deve ter 11 dígitos numéricos';
    } else if (tipoChavePix == 'E-mail') {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(valor)) return 'E-mail inválido';
    } else if (tipoChavePix == 'Número') {
      if (!RegExp(r'^\d{9}$').hasMatch(valor)) return 'Número deve ter 9 dígitos';
    }
    return null;
  }

  void _transferir() {
    double valor = double.tryParse(_valorController.text) ?? 0.0;
    String destinatario = _destinatarioController.text.trim();
    String? erroDest = validarDestinatario(destinatario);
    if (erroDest != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erroDest)),
      );
      return;
    }
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
      historico.add({
        'descricao': 'Pix para $destinatario ($tipoChavePix)',
        'valor': '- $simboloMoeda ${moedaSelecionada == 'BTC' ? valor.toStringAsFixed(6) : valor.toStringAsFixed(2)}',
        'data': DateTime.now().toIso8601String(),
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
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
    saldoBTC = args['saldoBTC'] ?? 1.0;
    if (args['historico'] != null && (args['historico'] as List).isNotEmpty) {
      historico = List<Map<String, dynamic>>.from(args['historico']);
    } else {
      historico = [];
    }
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
          'historico': historico,
        });
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Transferência', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          automaticallyImplyLeading: false, // REMOVE A SETA DE VOLTAR
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
                        Text(
                          'Olá $nome, faça uma transferência:',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Selecione a moeda para transferir:',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.darkRed, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _selecionarMoeda,
                          icon: Icon(
                            moedaSelecionada == 'BRL'
                                ? Icons.attach_money
                                : moedaSelecionada == 'USD'
                                    ? Icons.money
                                    : moedaSelecionada == 'EUR'
                                        ? Icons.euro
                                        : Icons.currency_bitcoin,
                            color: AppColors.darkRed,
                          ),
                          label: Text(_moedaNomes[moedaSelecionada]!),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Saldo disponível: $simboloMoeda ${moedaSelecionada == 'BTC' ? saldoAtual.toStringAsFixed(6) : saldoAtual.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tipo de chave Pix:',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: tipoChavePix,
                          dropdownColor: Colors.black,
                          items: ['CPF', 'E-mail', 'Número']
                              .map((tipo) => DropdownMenuItem(
                                    value: tipo,
                                    child: Text(tipo, style: const TextStyle(color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                tipoChavePix = value;
                                _destinatarioController.clear();
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _destinatarioController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: tipoChavePix == 'Número' || tipoChavePix == 'CPF'
                              ? TextInputType.number
                              : TextInputType.emailAddress,
                          inputFormatters: tipoChavePix == 'CPF'
                              ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)]
                              : tipoChavePix == 'Número'
                                  ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)]
                                  : [],
                          decoration: InputDecoration(
                            labelText: 'Destinatário (${tipoChavePix})',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF121212),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF333333)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF333333)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.darkRed),
                            ),
                            hintText: tipoChavePix == 'CPF'
                                ? 'Digite o CPF (11 dígitos)'
                                : tipoChavePix == 'E-mail'
                                    ? 'Digite o e-mail'
                                    : 'Digite o número (9 dígitos)',
                            hintStyle: const TextStyle(color: Colors.white38),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _valorController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Valor (${_moedaNomes[moedaSelecionada]})',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF121212),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF333333)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF333333)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.darkRed),
                            ),
                            hintText: 'Digite o valor',
                            hintStyle: const TextStyle(color: Colors.white38),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _transferir,
                          child: const Text('Transferir'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _abrirCamera,
                          icon: const Icon(Icons.qr_code, color: Colors.white),
                          label: const Text('Ler QR Code'),
                        ),
                        if (_imagemCamera != null) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_imagemCamera!, height: 120),
                          ),
                        ],
                        if (mensagem.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(mensagem, style: const TextStyle(color: Colors.white)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkRed,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Share.share(mensagem);
                            },
                            child: const Text('Compartilhar comprovante'),
                          ),
                        ],
                        // ADICIONE ESTE BOTÃO PARA FINALIZAR E VOLTAR
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('Finalizar'),
                          onPressed: () {
                            Navigator.pop(context, {
                              'saldoBRL': saldoBRL,
                              'saldoUSD': saldoUSD,
                              'saldoEUR': saldoEUR,
                              'saldoBTC': saldoBTC,
                              'historico': historico,
                            });
                          },
                        ),
                        const Spacer(),
                        Container(
                          color: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(color: Color(0xFF333333)),
                              const Text(
                                'Saldos totais:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              Text('BRL: R\$ ${saldoBRL.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white70)),
                              Text('USD: \$ ${saldoUSD.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white70)),
                              Text('EUR: € ${saldoEUR.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white70)),
                              Text('BTC: ${saldoBTC.toStringAsFixed(6)}',
                                  style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}