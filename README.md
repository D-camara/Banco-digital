# Banco Digital

Aplicativo Flutter de um banco digital fictício, desenvolvido para fins acadêmicos.

## Descrição

Este projeto simula um banco digital, permitindo ao usuário:
- Fazer login
- Visualizar saldos em múltiplas moedas (BRL, USD, EUR, BTC)
- Consultar cotações em tempo real via API
- Realizar transferências via Pix (CPF, E-mail ou Número)
- Visualizar histórico de transações e conversões
- Compartilhar comprovantes de transferência
- Utilizar câmera para simular leitura de QR Code

Não há integração com banco de dados real, todos os dados são mantidos em memória durante a execução.

## Telas implementadas

- **Login**
- **Principal**
- **Cotação** (com integração de API)
- **Transferência** (com validação Pix)

## Plugins utilizados

- [`http`](https://pub.dev/packages/http) — Requisições HTTP para API de cotação
- [`share_plus`](https://pub.dev/packages/share_plus) — Compartilhamento de comprovantes
- [`image_picker`](https://pub.dev/packages/image_picker) — Acesso à câmera (simulação de QR Code)

## Como rodar e gerar APK

1. Instale as dependências:
   ```
   flutter pub get
   ```
2. Rode o app em modo debug:
   ```
   flutter run
   ```
3. Para gerar APK otimizado (split por arquitetura):
   ```
   flutter build apk --split-per-abi
   ```
   Os APKs estarão em `build/app/outputs/flutter-apk/`.

## Observações importantes

- O histórico de transações é mantido entre as telas via argumentos de rota.
- O app utiliza rotas nomeadas e passagem de argumentos entre telas.
- Não há persistência de dados após fechar o app.
- O projeto está pronto para ser entregue compactado (.zip), incluindo os APKs split.

## Equipe

- [@D-camara](https://github.com/D-camara) (Daniel Camara)
- [@aallexandre](https://github.com/aallexandre) (Alexandre Nunes)
- [@ErrorDefault27](https://github.com/ErrorDefault27) (Edgar Caua)
- [@Faidherb](https://github.com/Faidherb) (Pedro Tocantins Faidherb)
- [@vintaodiniz](https://github.com/vintaodiniz) (Victor Diniz)

---

Projeto desenvolvido para fins didáticos.
