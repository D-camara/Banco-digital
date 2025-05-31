import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String usuario = '';
  String senha = '';
  bool _obscurePassword = true;

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(
        context,
        '/principal',
        arguments: {'nome': usuario},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.black, // Fundo preto
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: AppColors.red, // Detalhe em vermelho
                width: 2,
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Acesso ao Banco',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.red, // Detalhe em vermelho
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                      ), // Texto digitado em branco
                      decoration: InputDecoration(
                        labelText: 'Usuário',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ), // Label em branco
                        prefixIcon: Icon(
                          Icons.person,
                          color: AppColors.red,
                        ), // Detalhe em vermelho
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.red),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]+')),
                      ],
                      onChanged: (value) => usuario = value,
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Informe o usuário' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                      ), // Texto digitado em branco
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ), // Label em branco
                        prefixIcon: Icon(
                          Icons.lock,
                          color: AppColors.red,
                        ), // Detalhe em vermelho
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.red, // Detalhe em vermelho
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.red),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => senha = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter no mínimo 6 dígitos';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Entrar', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppColors {
  static const Color red = Color(0xFFB5121B);
  static const Color darkRed = Color(0xFF8A0F16);
  static const Color gray = Color(0xFFEEEEEE);
  static const Color white = Color(0xFF232323); // Alterado para cinza escuro
  static const Color black = Color(0xFF000000);
}
