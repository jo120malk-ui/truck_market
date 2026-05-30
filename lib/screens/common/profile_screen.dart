import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel? user;
  const ProfileScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: const Text('حسابي')),
        body: user == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile header
                    Container(
                      width: double.infinity,
                      color: AppTheme.primaryColor,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              user!.name.isNotEmpty ? user!.name[0].toUpperCase() : '؟',
                              style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(user!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: user!.isSeller ? AppTheme.secondaryColor : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user!.isSeller ? '🏪 تاجر' : '🛒 مشتري',
                              style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Info section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Column(
                          children: [
                            _infoTile(Icons.email_outlined, 'البريد الإلكتروني', user!.email),
                            const Divider(height: 1),
                            _infoTile(Icons.phone_outlined, 'رقم الجوال', user!.phone),
                            if (user!.city != null) ...[
                              const Divider(height: 1),
                              _infoTile(Icons.location_city_outlined, 'المدينة', user!.city!),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // Logout button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await authService.signOut();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (r) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                          label: const Text('تسجيل الخروج', style: TextStyle(color: AppTheme.errorColor, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.errorColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Cairo')),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo', fontSize: 15)),
    );
  }
}
