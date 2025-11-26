import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

const String _deleteRequestedKey = 'deleteAccountRequested';
const String _deleteDeadlineKey = 'deleteAccountDeadline';
const int _cancellationPeriodDays = 15;

class DeleteAccountScreen extends StatefulWidget {
  static const routeName = '/delete-account';
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isDeleteRequested = false;
  DateTime? _deleteDeadline;
  String _daysLeftText = '';
  Timer? _timer;

  final List<String> warningPoints = const [
    'Your email will be permanently deleted.',
    'All your memories on the app will be removed.',
    'Your username will be erased from our database.',
    'This action cannot be undone.',
    'You have $_cancellationPeriodDays days to cancel this request if you change your mind.',
  ];

  @override
  void initState() {
    super.initState();
    _loadDeleteStatus();
    _timer = Timer.periodic(const Duration(hours: 24), (timer) {
      if (mounted) {
        _updateDaysLeftText();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDeleteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isRequested = prefs.getBool(_deleteRequestedKey) ?? false;
    final deadlineTimestamp = prefs.getInt(_deleteDeadlineKey);

    DateTime? deadline;
    if (deadlineTimestamp != null) {
      deadline = DateTime.fromMillisecondsSinceEpoch(deadlineTimestamp);
    }

    if (mounted) {
      setState(() {
        _isDeleteRequested = isRequested;
        _deleteDeadline = deadline;
        _updateDaysLeftText();
      });

      if (_isDeleteRequested &&
          deadline != null &&
          deadline.isBefore(DateTime.now())) {
        _executePermanentDelete();
      }
    }
  }

  void _updateDaysLeftText() {
    if (!_isDeleteRequested || _deleteDeadline == null) {
      _daysLeftText = '';
      return;
    }

    final now = DateTime.now();
    final difference = _deleteDeadline!.difference(now);
    final daysLeft = difference.inDays;

    if (daysLeft > 0) {
      _daysLeftText = '$daysLeft days left!';
    } else if (difference.isNegative) {
      _daysLeftText = 'Account is being deleted...';
    } else {
      _daysLeftText = 'Less than 1 day left!';
    }
  }

  Future<void> _requestDelete() async {
    final prefs = await SharedPreferences.getInstance();

    final newDeadline = DateTime.now().add(
      const Duration(days: _cancellationPeriodDays),
    );

    await prefs.setBool(_deleteRequestedKey, true);
    await prefs.setInt(_deleteDeadlineKey, newDeadline.millisecondsSinceEpoch);

    if (mounted) {
      setState(() {
        _isDeleteRequested = true;
        _deleteDeadline = newDeadline;
        _updateDaysLeftText();
      });
    }
  }

  Future<void> _cancelDelete() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_deleteRequestedKey);
    await prefs.remove(_deleteDeadlineKey);

    if (mounted) {
      setState(() {
        _isDeleteRequested = false;
        _deleteDeadline = null;
        _daysLeftText = '';
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> _executePermanentDelete() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    if (mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = _isDeleteRequested ? 'Cancel ' : 'Delete Account';
    final onPressed = _isDeleteRequested ? _cancelDelete : _requestDelete;

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
                  Icon(Icons.arrow_back, size: 20, color: Colors.black),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.more_vert, size: 28, color: Colors.black),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  warningPoints
                      .map(
                        (point) => Padding(
                          padding: const EdgeInsets.only(bottom: 1.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '\u2022 ',
                                style: TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                  color: Colors.black,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  point,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.05,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isDeleteRequested
                          ? Colors.white
                          : const Color(0xFF333333),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side:
                        _isDeleteRequested
                            ? const BorderSide(color: Colors.black, width: 1)
                            : BorderSide.none,
                  ),
                  elevation: 5,
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: _isDeleteRequested ? Colors.black : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            if (_isDeleteRequested)
              Text(
                _daysLeftText,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
