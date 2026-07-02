import 'package:flutter/material.dart';
import 'package:edumov/services/config_service.dart';
import 'package:edumov/models/configuracao.dart';

class AssinaturaScreen extends StatefulWidget {
  const AssinaturaScreen({super.key});

  @override
  State<AssinaturaScreen> createState() => _AssinaturaScreenState();
}

class _AssinaturaScreenState extends State<AssinaturaScreen> {
  final ConfigService _configService = ConfigService();
  String _planoSelecionado = 'mensal';
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> _planos = {
    'mensal': {
      'nome': 'Mensal',
      'preco': 'R\$ 19,99',
      'periodo': '30 dias',
      'dias': 30,
      'icon': Icons.calendar_month,
    },
    'bimestral': {
      'nome': 'Bimestral',
      'preco': 'R\$ 35,98',
      'periodo': '60 dias',
      'dias': 60,
      'icon': Icons.calendar_view_month,
    },
    'semestral': {
      'nome': 'Semestral',
      'preco': 'R\$ 95,95',
      'periodo': '180 dias',
      'dias': 180,
      'icon': Icons.calendar_today,
    },
    'anual': {
      'nome': 'Anual',
      'preco': 'R\$ 167,91',
      'periodo': '365 dias',
      'dias': 365,
      'icon': Icons.calendar_month,
    },
  };

  Future<void> _confirmarAssinatura() async {
    setState(() => _isLoading = true);

    try {
      final config = await _configService.buscarConfiguracao();
      if (config != null) {
        final dias = _planos[_planoSelecionado]!['dias'] as int;
        final dataExpiracao = DateTime.now().add(Duration(days: dias));
        
        final configAtualizada = config.copyWith(
          plano: _planoSelecionado,
          assinaturaAtiva: true,
          dataExpiracao: dataExpiracao,
        );
        
        await _configService.atualizarConfiguracao(configAtualizada);
        
        // Ir para Home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar assinatura: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Assinar EduMov',
          style: TextStyle(color: Color(0xFF1A73E8)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF00BFA5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified_user,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Acesse todos os recursos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Escolha o plano que melhor atende sua necessidade',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Planos
              const Text(
                'Escolha seu plano',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ..._planos.keys.map((key) {
                final plano = _planos[key]!;
                final isSelected = _planoSelecionado == key;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _planoSelecionado = key);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF1A73E8).withOpacity(0.1)
                            : Colors.grey.shade50,
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF1A73E8)
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            plano['icon'] as IconData,
                            color: isSelected 
                                ? const Color(0xFF1A73E8)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plano['nome'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected 
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected 
                                        ? const Color(0xFF1A73E8)
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  plano['periodo'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            plano['preco'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? const Color(0xFF1A73E8)
                                  : Colors.black87,
                            ),
                          ),
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.check_circle,
                                color: Color(0xFF1A73E8),
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Benefícios
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildBeneficio(
                      Icons.check_circle_outline,
                      'Registrar atividades ilimitadas',
                    ),
                    _buildBeneficio(
                      Icons.check_circle_outline,
                      'Assinatura digital em PDF',
                    ),
                    _buildBeneficio(
                      Icons.check_circle_outline,
                      'Histórico completo de atividades',
                    ),
                    _buildBeneficio(
                      Icons.check_circle_outline,
                      'Relatórios personalizados',
                    ),
                    _buildBeneficio(
                      Icons.check_circle_outline,
                      'Suporte prioritário',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botão Confirmar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmarAssinatura,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Ativar Assinatura',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),
              
              Center(
                child: Text(
                  'Cancele quando quiser. Sem fidelidade.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeneficio(IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00BFA5), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}