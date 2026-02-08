import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state/skilltar_store.dart';
import '../app_router.dart';
import 'top_up_wallet_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'Skilltar User';
    final email = user?.email ?? 'user@skilltar.com';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Email
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Passionate Learner',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Credit Balance Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder<int>(
                valueListenable: SkilltarStore.I.credits,
                builder: (context, credits, _) {
                  return _CreditBalanceCard(credits: credits);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Achievements Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<List<dynamic>>(
                    valueListenable: SkilltarStore.I.bookings,
                    builder: (context, bookings, _) {
                      return _AchievementsSection(
                        totalBookings: bookings.length,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Management Section
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.settings,
                    title: 'Account Settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account Settings - Coming Soon'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Help & Support - Coming Soon'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuTile(
                    icon: Icons.logout,
                    title: 'Log Out',
                    titleColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();
              
              // Navigate back to role selection
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.roleSelection,
                  (_) => false,
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _CreditBalanceCard extends StatelessWidget {
  final int credits;

  const _CreditBalanceCard({required this.credits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Credit Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$credits',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'credits available',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to Top Up Wallet screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TopUpWalletScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Top Up Credits'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  final int totalBookings;

  const _AchievementsSection({required this.totalBookings});

  @override
  Widget build(BuildContext context) {
    // Define achievements
    final achievements = [
      _Achievement(
        title: 'Early Bird',
        description: 'Booked 5 workshops',
        icon: Icons.wb_sunny,
        isUnlocked: totalBookings >= 5,
        unlockedDate: totalBookings >= 5 ? DateTime.now() : null,
        color: Colors.orange,
      ),
      _Achievement(
        title: 'Workshop Master',
        description: 'Completed 20 workshops',
        icon: Icons.computer,
        isUnlocked: false,
        unlockedDate: null,
        color: Colors.blue,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: achievements.map((achievement) {
        return _AchievementBadge(achievement: achievement);
      }).toList(),
    );
  }
}

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final Color color;

  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.unlockedDate,
    required this.color,
  });
}

class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementBadge({required this.achievement});

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    
    return Container(
      width: (MediaQuery.of(context).size.width - 44) / 2, // 2 columns with spacing
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked 
              ? achievement.color.withOpacity(0.3) 
              : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          if (isUnlocked)
            BoxShadow(
              color: achievement.color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked 
                  ? achievement.color.withOpacity(0.15)
                  : Colors.grey[200],
            ),
            child: Icon(
              achievement.icon,
              size: 28,
              color: isUnlocked ? achievement.color : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 12),
          
          // Title
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.black : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          
          // Description
          Text(
            achievement.description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          // Unlock date (if unlocked)
          if (isUnlocked && achievement.unlockedDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: achievement.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatDate(achievement.unlockedDate!),
                style: TextStyle(
                  fontSize: 10,
                  color: achievement.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          
          // Locked status
          if (!isUnlocked) ...[
            const SizedBox(height: 8),
            Icon(
              Icons.lock,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}