import 'package:flutter/material.dart';
import 'package:connect_flutter/services/pocketbase.dart';

class AccountPage extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  const AccountPage({
    super.key,
    required this.isLoggedIn,
    required this.onRegister,
    required this.onLogin,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('accountPage'),
      children: [
        ListTile(
          leading: const Icon(Icons.app_registration),
          title: const Text('Register'),
          enabled: !isLoggedIn,
          onTap: !isLoggedIn ? onRegister : null,
        ),
        ListTile(
          leading: const Icon(Icons.login),
          title: const Text('Login'),
          enabled: !isLoggedIn,
          onTap: !isLoggedIn ? onLogin : null,
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          enabled: isLoggedIn,
          onTap: isLoggedIn ? onLogout : null,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.verified),
          title: const Text('AuthStore.isValid'),
          subtitle: Text('${pb.authStore.isValid}'),
        ),
        ListTile(
          leading: const Icon(Icons.fingerprint),
          title: const Text('AuthStore.record.id'),
          subtitle: Text(pb.authStore.record?.id ?? 'null'),
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('AuthStore.record.email'),
          subtitle: Text(pb.authStore.record?.data['email']?.toString() ?? 'null'),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('AuthStore.record.username'),
          subtitle: Text(pb.authStore.record?.data['user_name']?.toString() ?? 'null'),
        ),
      ],
    );
  }
}