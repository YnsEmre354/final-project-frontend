import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/core/services/local_notification_service.dart';
import 'package:flutter_turkce_ogrenme_application/features/splash/splash_screen.dart';

/*
Duzeltilcek Hatalar {
  Kullancıı adı değiştirebilir olsun 
  ad soyad ve email adresi değiştirilemez olsun
}
*/
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

/// 401 gibi hatalarda interceptor'dan login ekranına yönlendirmek için
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.init();
  HttpOverrides.global = MyHttpOverrides();

  runApp(ProviderScope(child: const MyApp()));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      navigatorObservers: [routeObserver],
      home: const SplashScreen(),
    );
  }
}
