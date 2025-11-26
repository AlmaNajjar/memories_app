import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/memories_provider.dart';
import '../models/memory.dart';
import './create_memory_screen.dart';
import './view_memory_screen.dart';
import './profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _navigateOrCreate(BuildContext context, {String? memoryId}) {
    Navigator.of(
      context,
    ).pushNamed(CreateMemoryScreen.routeName, arguments: memoryId);
  }

  void _navigateToView(BuildContext context, String memoryId) {
    Navigator.of(
      context,
    ).pushNamed(ViewMemoryScreen.routeName, arguments: memoryId);
  }

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      _MemoriesListContent(
        onCreateMemory: () => _navigateOrCreate(context),
        onViewMemory: (memoryId) => _navigateToView(context, memoryId),
      ),
      const PlaceholderScreen(
        title: 'Use the "+" icon below to create a memory',
      ),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _navigateOrCreate(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          Image.asset('assets/images/Logo 1 (2).png'),

          Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1.0)),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add, size: 32),
              activeIcon: Icon(Icons.add_circle),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 32),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex == 1 ? 0 : _selectedIndex,
          selectedItemColor: const Color(0xFF000000),
          unselectedItemColor: Colors.black54,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xffFFF5F5),
          elevation: 0,
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MemoriesListContent extends StatelessWidget {
  final VoidCallback onCreateMemory;
  final Function(String) onViewMemory;
  const _MemoriesListContent({
    required this.onCreateMemory,
    required this.onViewMemory,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MemoriesProvider>(
      builder: (ctx, memoriesData, child) {
        final memories = memoriesData.memories;

        if (memories.isEmpty) {
          return Center(child: _EmptyHomeContent(onCreate: onCreateMemory));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return _MemoryCard(memory: memory, onView: onViewMemory);
            },
          );
        }
      },
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final Memory memory;
  final Function(String) onView;
  const _MemoryCard({required this.memory, required this.onView});

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthName = months[date.month - 1];
    return '$monthName ${date.day} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onView(memory.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xffFFF5F5),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(memory.date),
              style: const TextStyle(
                fontSize: 11.36,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            Text(
              memory.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            Text(
              memory.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.36, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHomeContent extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyHomeContent({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/Vector.png'),
        const SizedBox(height: 30),

        const Text(
          'Create your first Memories',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          height: 39,
          child: OutlinedButton(
            onPressed: onCreate,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              side: const BorderSide(color: Colors.black54, width: 1.5),
            ),
            child: const Text(
              'Create',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
