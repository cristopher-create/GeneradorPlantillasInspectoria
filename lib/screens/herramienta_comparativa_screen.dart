// lib/screens/herramienta_comparativa_screen.dart

import 'package:flutter/material.dart';

class HerramientaComparativaScreen extends StatefulWidget {
  final List<String> codigosIniciales;
  final List<String> codigosActuales;

  const HerramientaComparativaScreen({
    super.key,
    required this.codigosIniciales,
    required this.codigosActuales,
  });

  @override
  State<HerramientaComparativaScreen> createState() => _HerramientaComparativaScreenState();
}

class _HerramientaComparativaScreenState extends State<HerramientaComparativaScreen> {
  int _currentIndex = 0;
  final List<String> _precios = ['S/. 5.00', 'S/. 4.00', 'S/. 3.00', 'S/. 2.50', 'S/. 2.00', 'S/. 1.50', 'S/. 1.00'];

  late List<List<bool>> _boletosEncontrados;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _boletosEncontrados = List.generate(7, (_) => []);
    _pageController = PageController();
    _pageController.addListener(() {
      final newIndex = _pageController.page?.round() ?? _currentIndex;
      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<int> _generarCodigos(int inicio, int corte, int ticketIndex) {
  List<int> codigos = [];
  if (inicio > corte) {
    // Caso de secuencia cíclica (ejemplo: inicio 957, corte 2)
    // El bucle para el corte debe ser hasta el número anterior (corte - 1)
    for (int i = corte - 1; i >= 0; i--) {
      codigos.add(i);
    }
    for (int i = 999; i >= inicio; i--) {
      codigos.add(i);
    }
  } else {
    // Caso de secuencia normal (ejemplo: inicio 523, corte 553)
    // El bucle debe ser hasta el número anterior (corte - 1)
    for (int i = corte - 1; i >= inicio; i--) {
      codigos.add(i);
    }
  }

  if (_boletosEncontrados[ticketIndex].isEmpty) {
    _boletosEncontrados[ticketIndex] = List.generate(codigos.length, (_) => false);
  }
  return codigos;
}

  Widget _buildTicketPage(List<int> indices) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: indices.map((index) {
            int? inicio = int.tryParse(widget.codigosIniciales[index]);
            int? corte = int.tryParse(widget.codigosActuales[index]);
            if (inicio == null || corte == null) {
              return const SizedBox.shrink();
            }
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TicketColumn(
                  precio: _precios[index],
                  codigos: _generarCodigos(inicio, corte, index),
                  boletosEncontrados: _boletosEncontrados[index],
                  onDoubleTap: (ticketListIndex) {
                    setState(() {
                      _boletosEncontrados[index][ticketListIndex] = !_boletosEncontrados[index][ticketListIndex];
                    });
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Estás seguro de que deseas salir?'),
        content: const Text('Se perderán todos los boletos marcados.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              backgroundColor: Colors.grey[200],
            ),
            child: const Text('Quedarse'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: const Text('Salir de todos modos'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final List<List<int>> pages = [
      [0, 1, 2],
      [3, 4, 5],
      [6],
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comparativa de Boletos'),
          backgroundColor: const Color(0xFF0D47A1),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final bool shouldPop = await _onWillPop();
              if (shouldPop) {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
          actions: const [],
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: pages.length,
          itemBuilder: (context, index) {
            return _buildTicketPage(pages[index]);
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentIndex == 0 ? 'S/. 5.00 - S/. 3.00' :
                _currentIndex == 1 ? 'S/. 2.50 - S/. 1.50' : 'S/. 1.00',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketColumn extends StatefulWidget {
  final String precio;
  final List<int> codigos;
  final List<bool> boletosEncontrados;
  final Function(int) onDoubleTap;

  const TicketColumn({
    super.key,
    required this.precio,
    required this.codigos,
    required this.boletosEncontrados,
    required this.onDoubleTap,
  });

  @override
  State<TicketColumn> createState() => _TicketColumnState();
}

class _TicketColumnState extends State<TicketColumn> {
  int _pageIndex = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    if (widget.codigos.isNotEmpty) {
      _pageIndex = 0;
    }
  }

  void _nextPage() {
    setState(() {
      if ((_pageIndex + 1) * _pageSize < widget.codigos.length) {
        _pageIndex++;
      }
    });
  }

  void _previousPage() {
    setState(() {
      if (_pageIndex > 0) {
        _pageIndex--;
      }
    });
  }

  List<int> _getCurrentPageCodes() {
    int start = _pageIndex * _pageSize;
    int end = (start + _pageSize).clamp(0, widget.codigos.length);
    return widget.codigos.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    List<int> currentPageCodes = _getCurrentPageCodes();

    return Column(
      children: [
        Text(widget.precio, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan)),
        IconButton(
          icon: const Icon(Icons.arrow_drop_up, size: 80),
          onPressed: _pageIndex > 0 ? _previousPage : null,
        ),
        SizedBox(
          height: 500,
          child: ListView.builder(
            itemCount: currentPageCodes.length,
            itemBuilder: (context, index) {
              int globalIndex = _pageIndex * _pageSize + index;
              return GestureDetector(
                onDoubleTap: () => widget.onDoubleTap(globalIndex),
                child: Container(
                  color: widget.boletosEncontrados[globalIndex] ? Colors.deepPurple : Colors.transparent,
                  child: Text(
                    currentPageCodes[index].toString().padLeft(3, '0'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 35, color: widget.boletosEncontrados[globalIndex] ? Colors.white : Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_drop_down, size: 80),
          onPressed: ((_pageIndex + 1) * _pageSize) < widget.codigos.length ? _nextPage : null,
        ),
      ],
    );
  }
}