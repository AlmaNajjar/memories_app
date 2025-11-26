import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../models/memory.dart';
import '../providers/memories_provider.dart';

class CreateMemoryScreen extends StatefulWidget {
  static const routeName = '/create-memory';

  const CreateMemoryScreen({super.key});

  @override
  State<CreateMemoryScreen> createState() => _CreateMemoryScreenState();
}

class _CreateMemoryScreenState extends State<CreateMemoryScreen> {
  final titleControl = FormControl<String>(validators: [Validators.required]);
  final contentControl = FormControl<String>(validators: [Validators.required]);

  Memory? _existingMemory;
  bool _isEditing = false;
  DateTime _currentDate = DateTime.now();

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final memoryIdFromRoute =
          ModalRoute.of(context)?.settings.arguments as String?;

      if (memoryIdFromRoute != null) {
        _isEditing = true;
        final memoriesProvider = Provider.of<MemoriesProvider>(
          context,
          listen: false,
        );
        _existingMemory = memoriesProvider.memories.firstWhere(
          (mem) => mem.id == memoryIdFromRoute,
          orElse: () => Memory.createNew(title: '', content: ''),
        );

        titleControl.value = _existingMemory!.title;
        contentControl.value = _existingMemory!.content;
        _currentDate = _existingMemory!.date;
        setState(() {});
      }
    });
  }

  void _saveMemory() {
    if (!titleControl.valid || !contentControl.valid) {
      titleControl.markAsTouched();
      contentControl.markAsTouched();
      return;
    }

    final provider = Provider.of<MemoriesProvider>(context, listen: false);

    if (_isEditing &&
        _existingMemory != null &&
        _existingMemory!.id.isNotEmpty) {
      final updatedMemory = _existingMemory!.copyWith(
        title: titleControl.value ?? '',
        content: contentControl.value ?? '',
        date: DateTime.now(),
      );
      provider.updateMemory(updatedMemory);
    } else {
      final newMemory = Memory.createNew(
        title: titleControl.value ?? '',
        content: contentControl.value ?? '',
      );
      provider.addMemory(newMemory);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
      body: ReactiveForm(
        formGroup: FormGroup({}),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ReactiveTextField<String>(
                formControl: titleControl,
                decoration: InputDecoration(
                  hintText: 'Set a Title',
                  hintStyle: TextStyle(
                    color:
                        _isEditing
                            ? const Color(0xff251D1D)
                            : const Color(0xffAD7575),
                  ),
                  filled: true,
                  fillColor: const Color(0xffFFF5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => 'Title cannot be empty.',
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF5F5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  _formatDate(_currentDate),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReactiveTextField<String>(
                  formControl: contentControl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Type your Thoughts',
                    filled: true,
                    hintStyle: TextStyle(
                      color:
                          _isEditing
                              ? const Color(0xff251D1D)
                              : const Color(0xffAD7575),
                    ),
                    fillColor: const Color(0xffFFF5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.black26,
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validationMessages: {
                    ValidationMessage.required:
                        (_) => 'Content cannot be empty.',
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveMemory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff333333),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'SAVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
