// Pantalla de cuenta: muestra el perfil del usuario con opciones
// de configuracion, suscripcion, historial y soporte.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/properties/ui/favorites_screen.dart';
import 'package:xatruch_realstate/features/profile/ui/settings_screen.dart';
import 'package:xatruch_realstate/features/profile/ui/profiles_screen.dart';
import 'package:xatruch_realstate/features/profile/ui/subscription_screen.dart';
import 'package:xatruch_realstate/features/support/ui/notifications_screen.dart';
import 'package:xatruch_realstate/features/support/ui/privacy_screen.dart';
import 'package:xatruch_realstate/features/support/ui/support_screen.dart';
import 'package:xatruch_realstate/features/profile/ui/sales_history_screen.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';
import 'package:xatruch_realstate/features/profile/ui/widgets/profile_header.dart';
import 'package:xatruch_realstate/features/profile/ui/widgets/profile_menu_tile.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = authService.currentUser;
    if (user != null) {
      final data = await userService.getUsuarioById(user.uid);
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _getUserName() {
    final nombre = _userData?['nombre'];
    if (nombre != null && nombre.toString().trim().isNotEmpty) {
      return nombre.toString();
    }

    final user = authService.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    if (user?.email != null) return user!.email!.split('@').first;

    return 'Usuario';
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ProfileHeader(
                    userName: _getUserName(),
                    userEmail: user?.email ?? 'Sin correo',
                    photoUrl: _userData?['photoUrl'] as String?,
                  ),
                  const SizedBox(height: 30),

                  ProfileMenuTile(
                    icon: Icons.person_outline,
                    title: 'Editar Perfil',
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const ProfileScreen(),
                        ),
                      ).then((_) => _loadUserData());
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.star_outline,
                    title: 'Suscripción',
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const SubscriptionScreen(),
                        ),
                      ).then((_) => _loadUserData());
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.favorite_border,
                    title: 'Favoritos',
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.history,
                    title: 'Historial de Ventas',
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const SalesHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.notifications_none,
                    title: 'Notificaciones',
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacidad y Seguridad',
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const PrivacyScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.help_outline,
                    title: 'Ayuda y Soporte',
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const SupportScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          await authService.signOut();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: colorScheme.error),
                          ),
                        ),
                        child: const Text('Cerrar Sesión'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
