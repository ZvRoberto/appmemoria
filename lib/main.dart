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
      title: 'Juego de Memoria',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
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
  final List<String> _simbolos = ['🐶', '🐱', '🐵', '🦊', '🐸', '🐼', '🦁', '🐷'];
  late List<String> _cartas;
  late List<bool> _volteadas;
  late List<bool> _emparejadas;

  int? _primeraSeleccion;
  int _intentos = 0;
  bool _bloqueado = false;

  @override
  void initState() {
    super.initState();
    _iniciarJuego();
  }

  void _iniciarJuego() {
    _cartas = [..._simbolos, ..._simbolos];
    _cartas.shuffle(Random());
    _volteadas = List.filled(_cartas.length, false);
    _emparejadas = List.filled(_cartas.length, false);
    _primeraSeleccion = null;
    _intentos = 0;
    _bloqueado = false;
  }

  void _voltearCarta(int indice) {
    if (_bloqueado || _volteadas[indice] || _emparejadas[indice]) return;

    setState(() => _volteadas[indice] = true);

    if (_primeraSeleccion == null) {
      _primeraSeleccion = indice;
      return;
    }

    _intentos++;
    final primera = _primeraSeleccion!;
    final segunda = indice;

    if (_cartas[primera] == _cartas[segunda]) {
      setState(() {
        _emparejadas[primera] = true;
        _emparejadas[segunda] = true;
        _primeraSeleccion = null;
      });
      _revisarVictoria();
    } else {
      _bloqueado = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() {
          _volteadas[primera] = false;
          _volteadas[segunda] = false;
          _primeraSeleccion = null;
          _bloqueado = false;
        });
      });
    }
  }

  void _revisarVictoria() {
    if (_emparejadas.every((e) => e)) {
      Future.delayed(const Duration(milliseconds: 300), () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('¡Ganaste! 🎉'),
            content: Text('Lo lograste en $_intentos intentos.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(_iniciarJuego);
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
        title: const Text('Juego de Memoria'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('Intentos: $_intentos')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _cartas.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, indice) {
            final mostrar = _volteadas[indice] || _emparejadas[indice];
            return GestureDetector(
              onTap: () => _voltearCarta(indice),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: mostrar
                      ? (_emparejadas[indice] ? Colors.green[200] : Colors.white)
                      : Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  mostrar ? _cartas[indice] : '❓',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(_iniciarJuego),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}