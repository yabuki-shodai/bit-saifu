import 'package:flutter/material.dart';
import 'package:bit_saifu/src/screen/home_screen.dart';
import 'package:bit_saifu/src/screen/ethereum_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  static const _pages = [
    BitcoinPage(),
    EthereumPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.currency_bitcoin),
            label: 'Bitcoin',
          ),
          NavigationDestination(
            icon: Icon(Icons.token),
            label: 'Ethereum',
          ),
        ],
      ),
    );
  }
}
