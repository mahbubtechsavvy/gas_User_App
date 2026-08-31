import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/locale_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/floating_pill_nav_bar.dart';
import '../cart/cart_screen.dart';
import '../order/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import 'home_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true, // Allows floating nav bar to overlay cleanly
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: FloatingPillNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          FloatingNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: loc.isBangla ? 'হোম' : 'Home',
          ),
          FloatingNavItem(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore_rounded,
            label: loc.isBangla ? 'এক্সপ্লোর' : 'Explore',
          ),
          FloatingNavItem(
            icon: Icons.shopping_cart_outlined,
            activeIcon: Icons.shopping_cart_rounded,
            label: loc.isBangla ? 'কার্ট' : 'Cart',
            badgeCount: cart.itemCount,
          ),
          FloatingNavItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: loc.isBangla ? 'অর্ডার' : 'Orders',
          ),
          FloatingNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: loc.isBangla ? 'প্রোফাইল' : 'Profile',
          ),
        ],
      ),
    );
  }
}
