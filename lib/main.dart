import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/principal.dart';
import 'screens/cotacao.dart';
import 'screens/transferencia.dart';

void main() {
  runApp(const BancoDigitalApp());
}

class BancoDigitalApp extends StatelessWidget {
  const BancoDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banco Digital',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/principal': (context) => const PrincipalScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/cotacao') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder:
                (context) => CotacaoScreen(
                  saldoBRL: args['saldoBRL'] ?? 1500.0,
                  saldoUSD: args['saldoUSD'] ?? 200.0,
                  saldoEUR: args['saldoEUR'] ?? 100.0,
                  saldoBTC: args['saldoBTC'] ?? 1.0, // Saldo inicial de 1 BTC
                ),
          );
        }
        if (settings.name == '/transferencia') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => TransferenciaScreen(args: args),
          );
        }
        return null;
      },
    );
  }
}
