import 'package:flutter/material.dart';
import 'package:bit_saifu/src/screen/home_screen.dart';
import 'package:bit_saifu/src/screen/ethereum_screen.dart';
import 'package:bit_saifu/src/screen/main_tab_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFF7931A),
        brightness: Brightness.light,
      ),
      home: const MainTabScreen(),
      routes: {
        '/ethereum': (context) => const EthereumPage(),
        '/bitcoin': (context) => const BitcoinPage(),
      },
    );
  }
}
