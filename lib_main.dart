import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Cinema',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: const TelaCinemas(),
    );
  }
}

class TelaCinemas extends StatefulWidget {
  const TelaCinemas({super.key});

  @override
  State<TelaCinemas> createState() => _EstadoTelaCinemas();
}

class _EstadoTelaCinemas extends State<TelaCinemas> {
  List<dynamic> listaCinemas = [];
  bool estaCarregando = true;
  String mensagemErro = '';

  @override
  void initState() {
    super.initState();
    buscarCinemas();
  }

  Future<void> buscarCinemas() async {
    try {
      final resposta = await http.get(
        Uri.parse('https://arquivos.ectare.com.br/cinemas.json'),
      );

      if (resposta.statusCode == 200) {
        setState(() {
          listaCinemas = json.decode(resposta.body);
          estaCarregando = false;
        });
      } else {
        setState(() {
          mensagemErro = 'Falha ao carregar dados: ${resposta.statusCode}';
          estaCarregando = false;
        });
      }
    } catch (erro) {
      setState(() {
        mensagemErro = 'Erro de conexão: $erro';
        estaCarregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cinemas',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: estaCarregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : mensagemErro.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        mensagemErro,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: buscarCinemas,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: buscarCinemas,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listaCinemas.length,
                    itemBuilder: (context, indice) {
                      final cinema = listaCinemas[indice];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.movie_creation,
                                    color: Colors.purple,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      cinema['nome'] ?? 'Nome não disponível',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _construirLinhaInfo(
                                Icons.location_on,
                                'Localização:',
                                cinema['localizacao'] ?? 'Não informada',
                              ),
                              const SizedBox(height: 12),
                              _construirLinhaInfo(
                                Icons.people,
                                'Capacidade:',
                                '${cinema['capacidade'] ?? 'Não informada'} pessoas',
                              ),
                              const SizedBox(height: 12),
                              _construirLinhaInfo(
                                Icons.meeting_room,
                                'Número de Salas:',
                                '${cinema['numero_salas'] ?? 'Não informado'} salas',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _construirLinhaInfo(IconData icone, String rotulo, String valor) {
    return Row(
      children: [
        Icon(
          icone,
          color: Colors.purple[300],
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          rotulo,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            valor,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}