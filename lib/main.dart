import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/config/app_config.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/cart_provider.dart';
import 'package:userapp/providers/order_provider.dart';
import 'package:userapp/providers/product_provider.dart';
import 'package:userapp/providers/vendor_provider.dart';
import 'package:userapp/services/notification_service.dart';
import 'package:userapp/splash_screen.dart';
import 'package:userapp/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeFirebase();
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

