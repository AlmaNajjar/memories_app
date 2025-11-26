import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/memory.dart';
import '../providers/memories_provider.dart';
import './create_memory_screen.dart';

class ViewMemoryScreen extends StatelessWidget {
  static const routeName = '/view-memory';

  const ViewMemoryScreen({super.key});

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

  void _navigateToEdit(BuildContext context, String memoryId) {
    Navigator.of(
      context,
    ).pushNamed(CreateMemoryScreen.routeName, arguments: memoryId);
  }

  @override
  Widget build(BuildContext context) {
    final memoryId = ModalRoute.of(context)?.settings.arguments as String?;

    if (memoryId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Memory ID not provided.')),
      );
    }

    return Consumer<MemoriesProvider>(
      builder: (context, memoriesData, child) {
        final Memory? memory = memoriesData.memories.firstWhere(
          (mem) => mem.id == memoryId,
          orElse:
              () => Memory.createNew(
                title: 'Not Found',
                content: 'This memory was not found.',
              ),
        );

        if (memory?.title == 'Not Found') {
          return Scaffold(
            appBar: AppBar(title: const Text('Memory Not Found')),
            body: const Center(
              child: Text('The requested memory does not exist.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 20),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () => _navigateToEdit(context, memory!.id),
                  child: const Icon(Icons.more_vert, size: 28),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory!.title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff251D1D),
                  ),
                ),

                Text(
                  _formatDate(memory.date),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff161616),
                  ),
                ),

                Text(
                  memory.content,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
