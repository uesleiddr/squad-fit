import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/user_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _initialWeightController = TextEditingController();
  final _goalWeightController = TextEditingController();

  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Tenta separar nome e sobrenome do displayName
      final nameParts = (user.displayName ?? '').split(' ');
      if (nameParts.isNotEmpty) {
        _firstNameController.text = nameParts.first;
        if (nameParts.length > 1) {
          _lastNameController.text = nameParts.sublist(1).join(' ');
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _heightController.dispose();
    _initialWeightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: 'Selecione sua data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      await _userService.createUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: user?.email ?? '',
        photoUrl: user?.photoURL,
        height: int.tryParse(_heightController.text),
        initialWeight: double.tryParse(_initialWeightController.text.replaceAll(',', '.')),
        goalWeight: double.tryParse(_goalWeightController.text.replaceAll(',', '.')),
        birthDate: _birthDate,
      );

      if (mounted) {
        // Volta para o AuthWrapper que vai detectar o perfil completo
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete seu perfil'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Precisamos de algumas informacoes para comecar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Nome
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sobrenome
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Sobrenome',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu sobrenome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Data de nascimento
                InkWell(
                  onTap: _selectBirthDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _birthDate != null
                          ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                          : 'Selecione',
                      style: TextStyle(
                        color: _birthDate != null ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Altura
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Altura (cm)',
                    prefixIcon: Icon(Icons.height),
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 175',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Peso inicial
                TextFormField(
                  controller: _initialWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Peso atual (kg)',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 85.5',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu peso atual';
                    }
                    final weight = double.tryParse(value.replaceAll(',', '.'));
                    if (weight == null || weight <= 0) {
                      return 'Peso invalido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Peso meta
                TextFormField(
                  controller: _goalWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Peso meta (kg)',
                    prefixIcon: Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 75.0',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 32),

                // Botão salvar
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
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
                            'Comecar',
                            style: TextStyle(fontSize: 16),
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
