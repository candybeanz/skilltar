import 'package:flutter/material.dart';
import '../app_router.dart';

enum UserRole { client, host }

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selected = UserRole.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skilltar'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose your role',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'This helps us show the correct features for you.',
                ),
              ),
              const SizedBox(height: 16),

              _roleCard(
                role: UserRole.client,
                title: "I'm a Client",
                subtitle: 'Discover & book workshops using credits.',
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              _roleCard(
                role: UserRole.host,
                title: "I'm a Host",
                subtitle: 'Upload verification & create workshop slots.',
                icon: Icons.storefront,
              ),

              const Spacer(),

              if (_selected == UserRole.host)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Note: Hosts must complete verification before creating slots.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_selected == UserRole.client) {
                      Navigator.pushNamed(
                        context,
                        Routes.login,
                        arguments: const LoginArgs(UserRole.client),
                      );
                    } else {
                      Navigator.pushNamed(context, Routes.hostDashboard);
                    }
                  },
                  child: const Text('Continue'),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.login,
                        arguments: LoginArgs(_selected),
                      );
                    },
                    child: const Text('Log in'),
                  ),
                  const Text('•'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.signup,
                        arguments: SignupArgs(_selected),
                      );
                    },
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selected == role;

    return Card(
      elevation: selected ? 2 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selected = role),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              Radio<UserRole>(
                value: role,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
