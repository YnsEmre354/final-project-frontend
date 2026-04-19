import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_turkce_ogrenme_application/features/auth/login/login_screen.dart';

/*
Duzeltilcek Hatalar {
  logindeki controller lar clear edilmiyor.

  Kullancıı adı değiştirebilir olsun 
  ad soyad ve email adresi değiştirilemez olsun
  


}



*/
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      navigatorObservers: [routeObserver],

      home: const LoginScreen(),
    );
  }
}
