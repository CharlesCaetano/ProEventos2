import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<dynamic> _clientes = [];
  List<dynamic> _filtrados = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final clientes = await ApiService.getClientes();
    setState(() {
      _clientes = clientes;
      _filtrados = clientes;
      _loading = false;
    });
  }

  void _filtrar(String texto) {
    setState(() {
      _filtrados = _clientes.where((c) {
        final nome = (c['nome'] ?? '').toString().toLowerCase();
        final cpf = (c['cpf_cnpj'] ?? '').toString().toLowerCase();
        return nome.contains(texto.toLowerCase()) || cpf.contains(texto.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Pesquisar cliente...',
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
                      final cliente = _filtrados[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Text(
                              (cliente['nome'] ?? '?')[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(cliente['nome'] ?? ''),
                          subtitle: Text('${cliente['cpf_cnpj'] ?? ''} - ${cliente['cidade'] ?? ''}/${cliente['uf'] ?? ''}'),
                          trailing: Text(cliente['telefone'] ?? '',
                            style: const TextStyle(fontSize: 12)),
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
