import 'package:flutter/material.dart';

class BottomNavScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const BottomNavScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: actions,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            items: items,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
        ),
      ),
      extendBody: true, // Important for floating effect
    );
  }
}
