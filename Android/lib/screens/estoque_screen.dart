import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  List<dynamic> _itens = [];
  List<dynamic> _filtrados = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final itens = await ApiService.getEstoque();
    setState(() {
      _itens = itens;
      _filtrados = itens;
      _loading = false;
    });
  }

  void _filtrar(String texto) {
    setState(() {
      _filtrados = _itens.where((item) {
        final desc = (item['descricao'] ?? '').toString().toLowerCase();
        final cod = (item['codigo'] ?? '').toString().toLowerCase();
        return desc.contains(texto.toLowerCase()) || cod.contains(texto.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Pesquisar produto...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filtrar,
            ),
          ),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: ListView.builder(
                    itemCount: _filtrados.length,
                    itemBuilder: (context, index) {
                      final item = _filtrados[index];
                      final qtd = (item['quantidade'] ?? 0).toDouble();
                      final min = (item['estoque_minimo'] ?? 0).toDouble();
                      final abaixoMinimo = min > 0 && qtd < min;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        color: abaixoMinimo ? Colors.red.shade50 : null,
                        child: ListTile(
                          leading: Icon(
                            Icons.inventory_2,
                            color: abaixoMinimo ? Colors.red : Colors.teal,
                          ),
                          title: Text(item['descricao'] ?? ''),
                          subtitle: Text('Cód: ${item['codigo'] ?? ''}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${qtd.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: abaixoMinimo ? Colors.red : Colors.black,
                                ),
                              ),
                              if (abaixoMinimo)
                                Text('Mín: ${min.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 11, color: Colors.red)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
