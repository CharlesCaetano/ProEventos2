import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VendasScreen extends StatefulWidget {
  const VendasScreen({super.key});

  @override
  State<VendasScreen> createState() => _VendasScreenState();
}

class _VendasScreenState extends State<VendasScreen> {
  List<dynamic> _vendas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final vendas = await ApiService.getVendas();
    setState(() {
      _vendas = vendas;
      _loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Faturado': return Colors.green;
      case 'Aprovado': return Colors.blue;
      case 'Pendente': return Colors.orange;
      case 'Cancelado': return Colors.red;
      case 'Orçamento': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendas'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _carregar,
            child: ListView.builder(
              itemCount: _vendas.length,
              itemBuilder: (context, index) {
                final venda = _vendas[index];
                final total = (venda['total'] ?? 0).toDouble();
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(venda['status'] ?? ''),
                      child: Text('${venda['numero'] ?? ''}',
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    title: Text(venda['cliente'] ?? 'Consumidor'),
                    subtitle: Text('${venda['data_emissao'] ?? ''} - ${venda['status'] ?? ''}'),
                    trailing: Text(
                      'R\$ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
    );
  }
}
