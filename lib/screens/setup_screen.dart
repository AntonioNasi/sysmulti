import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edumov/services/config_service.dart';
import 'package:edumov/models/configuracao.dart';
import 'package:edumov/services/database_service.dart';
import 'package:edumov/models/membro.dart';
import 'package:edumov/utils/validators.dart';
import 'package:edumov/widgets/custom_text_field.dart';
import 'package:edumov/screens/assinatura_screen.dart';
import 'dart:io';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _configService = ConfigService();
  final _databaseService = DatabaseService();

  final _nomeController = TextEditingController();
  final _cargoController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _isLoading = false;
  bool _mostrarSenha = false;
  bool _mostrarConfirmarSenha = false;
  File? _assinaturaImagem;

  @override
  void dispose() {
    _nomeController.dispose();
    _cargoController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarAssinatura() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 300,
    );
    
    if (pickedFile != null) {
      setState(() {
        _assinaturaImagem = File(pickedFile.path);
      });
    }
  }

  Future<void> _concluirSetup() async {
  if (!_formKey.currentState!.validate()) return;
  if (_assinaturaImagem == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, adicione sua assinatura digitalizada'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // ✅ USAR O PARÂMETRO CORRETO: nomeTecnico
    final config = Configuracao(
      nomeTecnico: _nomeController.text.trim(),  // ← nomeTecnico (não nomeOrganizacao)
      cargo: _cargoController.text.trim(),       // ← cargo existe no modelo
      assinaturaPath: _assinaturaImagem?.path,   // ← assinaturaPath existe no modelo
      setupConcluido: true,
      assinaturaAtiva: false,
    );

    await _configService.salvarConfiguracao(config);
    print('✅ Configuração salva com sucesso!');

    // Criar usuário
    try {
      final admin = Membro(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
        tipo: 'Administrador',
        ativo: true,
        dataCadastro: DateTime.now(),
      );
      await _databaseService.inserirMembro(admin);
      print('✅ Membro criado com sucesso!');
    } catch (e) {
      print('Erro ao criar membro: $e');
    }

    // Ir para tela de assinatura
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AssinaturaScreen(),
        ),
      );
    }
  } catch (e) {
    print('❌ Erro ao concluir setup: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao concluir setup: $e'),
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
          'Configuração Inicial',
          style: TextStyle(color: Color(0xFF1A73E8)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/imagens/eduMov_logo.png',
                        height: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bem-vindo ao EduMov!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A73E8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Configure seu perfil para começar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Dados do Técnico
                const Text(
                  'Seus Dados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _nomeController,
                  label: 'Nome Completo',
                  hint: 'Ex: Pedro Silva',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _cargoController,
                  label: 'Cargo',
                  hint: 'Ex: Técnico Educacional',
                  icon: Icons.work,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite seu cargo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite seu e-mail';
                    }
                    if (!Validators.isValidEmail(value.trim())) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _senhaController,
                  label: 'Senha',
                  hint: 'Mínimo 6 caracteres',
                  icon: Icons.lock,
                  obscureText: !_mostrarSenha,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarSenha ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _mostrarSenha = !_mostrarSenha);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite uma senha';
                    }
                    if (value.length < 6) {
                      return 'Senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _confirmarSenhaController,
                  label: 'Confirmar Senha',
                  hint: 'Digite a senha novamente',
                  icon: Icons.lock_outline,
                  obscureText: !_mostrarConfirmarSenha,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarConfirmarSenha ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _mostrarConfirmarSenha = !_mostrarConfirmarSenha);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme a senha';
                    }
                    if (value != _senhaController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Assinatura
                const Text(
                  'Assinatura Digitalizada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecione uma imagem da sua assinatura',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: _selecionarAssinatura,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _assinaturaImagem != null 
                            ? Colors.green 
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: _assinaturaImagem != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _assinaturaImagem!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Toque para selecionar a assinatura',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botão
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _concluirSetup,
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
                            'Continuar para Assinatura',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Após configurar seu perfil, você precisará\nassinar um plano para usar o app',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}