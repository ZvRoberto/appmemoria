import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Juego de Memoria',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const PantallaMemoria(),
    );
  }
}

class PantallaMemoria extends StatefulWidget {
  const PantallaMemoria({super.key});

  @override
  State<PantallaMemoria> createState() => _PantallaMemoriaState();
}

class _PantallaMemoriaState extends State<PantallaMemoria> {
  final List<String> _simbolos = ['🇬🇹', 'R', '|||'];

  late List<String> _cartas;
  late List<bool> _volteadas;
  late List<bool> _emparejadas;

  List<int> _seleccionadas = [];

  int _intentos = 0;
  bool _bloqueado = false;

  @override
  void initState() {
    super.initState();
    _iniciarJuego();
  }

  void _iniciarJuego() {
    // Cada símbolo aparece 3 veces
    _cartas = [
      ..._simbolos,
      ..._simbolos,
      ..._simbolos,
    ];

    _cartas.shuffle(Random());

    _volteadas = List.filled(_cartas.length, false);
    _emparejadas = List.filled(_cartas.length, false);

    _seleccionadas = [];
    _intentos = 0;
    _bloqueado = false;
  }

  void _voltearCarta(int indice) {
    if (_bloqueado ||
        _volteadas[indice] ||
        _emparejadas[indice]) {
      return;
    }

    setState(() {
      _volteadas[indice] = true;
      _seleccionadas.add(indice);
    });

    // Esperar hasta seleccionar 3 cartas
    if (_seleccionadas.length < 3) {
      return;
    }

    _intentos++;
    _bloqueado = true;

    final primera = _seleccionadas[0];
    final segunda = _seleccionadas[1];
    final tercera = _seleccionadas[2];

    // Comprobar si las 3 son iguales
    if (_cartas[primera] == _cartas[segunda] &&
        _cartas[segunda] == _cartas[tercera]) {
      setState(() {
        _emparejadas[primera] = true;
        _emparejadas[segunda] = true;
        _emparejadas[tercera] = true;

        _seleccionadas = [];
        _bloqueado = false;
      });

      _revisarVictoria();
    } else {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;

        setState(() {
          _volteadas[primera] = false;
          _volteadas[segunda] = false;
          _volteadas[tercera] = false;

          _seleccionadas = [];
          _bloqueado = false;
        });
      });
    }
  }

  void _revisarVictoria() {
    if (_emparejadas.every((e) => e)) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('¡Ganaste! 🎉'),
            content: Text(
              'Encontraste todos los grupos de 3 en $_intentos intentos.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  setState(() {
                    _iniciarJuego();
                  });
                },
                child: const Text('Jugar de nuevo'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      appBar: AppBar(
        title: const Text('Memoria de 3'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Intentos: $_intentos',
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _cartas.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, indice) {
            final mostrar =
                _volteadas[indice] || _emparejadas[indice];

            return GestureDetector(
              onTap: () => _voltearCarta(indice),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: mostrar
                      ? (_emparejadas[indice]
                          ? Colors.green[200]
                          : Colors.white)
                      : Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  mostrar ? _cartas[indice] : '❓',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _iniciarJuego();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}