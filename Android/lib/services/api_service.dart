// ============================================================
// ERP 2026 - Serviço de API
// Descrição: Comunicação com a API REST do ERP
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Altere para o IP do servidor onde a API Horse está rodando
  static const String baseUrl = 'http://192.168.1.100:9000/api';

  static String? _token;

  static Future<String?> get token async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    return _token;
  }

  static Future<Map<String, String>> get _headers async {
    final t = await token;
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  // LOGIN
  static Future<Map<String, dynamic>?> login(String usuario, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login': usuario, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        await prefs.setString('usuario_nome', data['nome'] ?? '');
        await prefs.setInt('usuario_id', data['usuario_id'] ?? 0);
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // CLIENTES
  static Future<List<dynamic>> getClientes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  // PRODUTOS
  static Future<List<dynamic>> getProdutos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produtos'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  // ESTOQUE
  static Future<List<dynamic>> getEstoque() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estoque'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  // VENDAS
  static Future<List<dynamic>> getVendas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vendas'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  // FINANCEIRO - Resumo
  static Future<Map<String, dynamic>> getResumoFinanceiro() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/financeiro'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {};
  }

  // FINANCEIRO - Contas a Receber
  static Future<List<dynamic>> getContasReceber() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/financeiro/receber'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  // FINANCEIRO - Contas a Pagar
  static Future<List<dynamic>> getContasPagar() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/financeiro/pagar'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }
}
