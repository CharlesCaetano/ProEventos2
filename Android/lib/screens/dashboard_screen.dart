import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'estoque_screen.dart';
import 'vendas_screen.dart';
import 'financeiro_screen.dart';
import 'clientes_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _resumo = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final resumo = await ApiService.getResumoFinanceiro();
    setState(() {
      _resumo = resumo;
      _loading = false;
    });
  }

  String _formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ERP 2026'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () { setState(() { _loading = true; }); _carregarDados(); },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _carregarDados,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // KPIs
                  Row(
                    children: [
                      Expanded(child: _buildKPICard(
                        'Faturamento Mês',
                        _formatarValor((_resumo['faturamento_mes'] ?? 0).toDouble()),
                        Icons.trending_up,
                        Colors.green,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKPICard(
                        'Vendas Mês',
                        '${_resumo['vendas_mes'] ?? 0}',
                        Icons.shopping_cart,
                        Colors.blue,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildKPICard(
                        'A Receber',
                        _formatarValor((_resumo['a_receber'] ?? 0).toDouble()),
                        Icons.arrow_downward,
                        Colors.orange,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKPICard(
                        'A Pagar',
                        _formatarValor((_resumo['a_pagar'] ?? 0).toDouble()),
                        Icons.arrow_upward,
                        Colors.red,
                      )),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text('Módulos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Módulos
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildModuleCard('Clientes', Icons.people, Colors.indigo, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientesScreen()));
                      }),
                      _buildModuleCard('Estoque', Icons.inventory, Colors.teal, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EstoqueScreen()));
                      }),
                      _buildModuleCard('Vendas', Icons.point_of_sale, Colors.green, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const VendasScreen()));
                      }),
                      _buildModuleCard('Financeiro', Icons.account_balance, Colors.amber, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceiroScreen()));
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
