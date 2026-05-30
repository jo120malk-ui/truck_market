import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import 'listings_screen.dart';
import 'profile_screen.dart';
import '../seller/my_listings_screen.dart';
import '../seller/add_listing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  UserModel? _user;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUserProfile();
    if (mounted) setState(() => _user = user);
  }

  List<Widget> get _screens => [
    const ListingsScreen(),
    if (_user?.isSeller == true) const MyListingsScreen(),
    ProfileScreen(user: _user),
  ];

  List<BottomNavigationBarItem> get _navItems => [
    const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
    if (_user?.isSeller == true)
      const BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'إعلاناتي'),
    const BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
          items: _navItems,
        ),
        floatingActionButton: _user?.isSeller == true && _currentIndex == 1
            ? FloatingActionButton.extended(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingScreen()));
                  setState(() {});
                },
                backgroundColor: AppTheme.secondaryColor,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('إضافة إعلان', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
              )
            : null,
      ),
    );
  }
}
