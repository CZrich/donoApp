import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.title,
    required this.child,
    this.currentIndex,
    super.key,
  });

  final String title;
  final Widget child;
  final int? currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(padding: const EdgeInsets.all(20), child: child),
          ),
        ),
      ),
      bottomNavigationBar: currentIndex == null
          ? null
          : NavigationBar(
              selectedIndex: currentIndex!,
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/donor');
                  case 1:
                    context.go('/history');
                  case 2:
                    context.go('/profile');
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history),
                  label: 'Historial',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            ),
    );
  }
}
