import 'package:alimentored/app/theme/app_colors.dart';
import 'package:alimentored/core/presentation/app_page.dart';
import 'package:alimentored/features/auth/application/auth_controller.dart';
import 'package:alimentored/features/profile/application/profile_controller.dart';
import 'package:alimentored/features/profile/domain/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRole;
  bool _isSaving = false;
  String? _statusMessage;
  bool _isSuccess = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populate(UserProfileModel profile) {
    if (!_initialized) {
      _nameController.text = profile.displayName ?? '';
      _phoneController.text = profile.phone ?? '';
      _selectedRole = profile.role;
      _initialized = true;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    final success =
        await ref.read(profileControllerProvider.notifier).updateProfile(
              displayName: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              role: _selectedRole,
            );

    if (mounted) {
      setState(() {
        _isSaving = false;
        _isSuccess = success;
        _statusMessage = success
            ? 'Perfil actualizado con éxito.'
            : 'No se pudo actualizar el perfil. Intenta nuevamente.';
      });
    }
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return AppPage(
      title: 'Mi Perfil',
      currentIndex: 2,
      child: profileState.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No se pudo cargar el perfil',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () =>
                        ref.read(profileControllerProvider.notifier).reload(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (profile) {
          _populate(profile);

          final initials = (profile.displayName?.isNotEmpty ?? false)
              ? profile.displayName![0].toUpperCase()
              : (profile.email.isNotEmpty ? profile.email[0].toUpperCase() : 'U');

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.greenDark,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.lime,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.displayName?.isNotEmpty ?? false
                        ? profile.displayName!
                        : 'Usuario sin nombre registrado',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: const TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_statusMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isSuccess
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isSuccess
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSuccess
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: _isSuccess
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusMessage!,
                              style: TextStyle(
                                color: _isSuccess
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.security,
                                  size: 18, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(
                                'Datos de cuenta protegidos',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: profile.email,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                              helperText:
                                  'El correo no se puede modificar desde el formulario general.',
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (profile.role != null) ...[
                            InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Rol asignado',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
                                helperText:
                                    'El rol de la cuenta está protegido contra modificaciones accidentales.',
                              ),
                              child: Text(
                                profile.role == 'donor'
                                    ? 'Donante de alimentos'
                                    : 'Organización social',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ] else ...[
                            DropdownButtonFormField<String>(
                              key: const Key('profile_role_select'),
                              initialValue: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Selecciona tu rol inicial',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
                                helperText:
                                    'Una vez guardado, el rol queda protegido.',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'donor',
                                  child: Text('Donante'),
                                ),
                                DropdownMenuItem(
                                  value: 'organization',
                                  child: Text('Organización social'),
                                ),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedRole = val;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de contacto',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            key: const Key('profile_name_input'),
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Nombre completo / Representante',
                              hintText: 'Ej. Juan Pérez',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              final trimmed = val?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return 'Ingresa tu nombre o el del responsable';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            key: const Key('profile_phone_input'),
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono de contacto',
                              hintText: '+51 987 654 321',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              final trimmed = val?.trim() ?? '';
                              if (trimmed.isNotEmpty && trimmed.length < 6) {
                                return 'Ingresa un número de teléfono válido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('profile_save_button'),
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Guardar cambios'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('profile_logout_button'),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
