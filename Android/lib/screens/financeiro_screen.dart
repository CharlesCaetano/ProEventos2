import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FinanceiroScreen extends StatefulWidget {
  const FinanceiroScreen({super.key});

  @override
  State<FinanceiroScreen> createState() => _FinanceiroScreenState();
}

class _FinanceiroScreenState extends State<FinanceiroScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _receber = [];
  List<dynamic> _pagar = [];
  Map<String, dynamic> _resumo = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregar();
  }

  Future<void> _carregar() async {
    final receber = await ApiService.getContasReceber();
    final pagar = await ApiService.getContasPagar();
    final resumo = await ApiService.getResumoFinanceiro();
    setState(() {
      _receber = receber;
      _pagar = pagar;
      _resumo = resumo;
      _loading = false;
    });
  }

  String _formatarValor(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financeiro'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Resumo'),
            Tab(text: 'A Receber'),
            Tab(text: 'A Pagar'),
          ],
        ),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildResumo(),
              _buildLista(_receber, 'cliente', Colors.green),
              _buildLista(_pagar, 'fornecedor', Colors.red),
            ],
          ),
    );
  }

  Widget _buildResumo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildResumoCard('Faturamento do Mês',
            _formatarValor((_resumo['faturamento_mes'] ?? 0).toDouble()),
            Icons.trending_up, Colors.green),
          _buildResumoCard('Vendas do Mês',
            '${_resumo['vendas_mes'] ?? 0} vendas',
            Icons.shopping_cart, Colors.blue),
          _buildResumoCard('Total a Receber',
            _formatarValor((_resumo['a_receber'] ?? 0).toDouble()),
            Icons.arrow_downward, Colors.orange),
          _buildResumoCard('Total Recebido',
            _formatarValor((_resumo['recebido'] ?? 0).toDouble()),
            Icons.check_circle, Colors.green),
          _buildResumoCard('Total a Pagar',
            _formatarValor((_resumo['a_pagar'] ?? 0).toDouble()),
            Icons.arrow_upward, Colors.red),
          _buildResumoCard('Total Pago',
            _formatarValor((_resumo['pago'] ?? 0).toDouble()),
            Icons.check_circle_outline, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildResumoCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color, size: 36),
        title: Text(title),
        trailing: Text(value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  Widget _buildLista(List<dynamic> contas, String entityField, Color color) {
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.builder(
        itemCount: contas.length,
        itemBuilder: (context, index) {
          final conta = contas[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: Icon(Icons.receipt, color: color),
              title: Text(conta[entityField] ?? conta['descricao'] ?? ''),
              subtitle: Text('Venc: ${conta['vencimento'] ?? ''}'),
              trailing: Text(
                _formatarValor((conta['valor'] ?? 0).toDouble()),
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          );
        },
      ),
    );
  }
}
