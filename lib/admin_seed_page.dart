import 'package:flutter/material.dart';
import '../services/firestore_seeder.dart';

/// Admin page để seed mock data vào Firestore
/// Chỉ dùng khi development
class AdminSeedPage extends StatefulWidget {
  const AdminSeedPage({super.key});

  @override
  State<AdminSeedPage> createState() => _AdminSeedPageState();
}

class _AdminSeedPageState extends State<AdminSeedPage> {
  final FirestoreSeeder _seeder = FirestoreSeeder();
  bool _isSeeding = false;
  String _message = '';

  Future<void> _seedData() async {
    setState(() {
      _isSeeding = true;
      _message = 'Seeding data...';
    });

    try {
      await _seeder.seedAll();
      setState(() {
        _message = '✅ Success! Mock data has been seeded.';
        _isSeeding = false;
      });
    } catch (e) {
      setState(() {
        _message = '❌ Error: $e';
        _isSeeding = false;
      });
    }
  }

  Future<void> _clearData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Warning'),
        content: const Text('This will delete ALL songs, artists, and albums. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSeeding = true;
      _message = 'Clearing data...';
    });

    try {
      await _seeder.clearAll();
      setState(() {
        _message = '✅ All data cleared.';
        _isSeeding = false;
      });
    } catch (e) {
      setState(() {
        _message = '❌ Error: $e';
        _isSeeding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Admin - Seed Data'),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'SoulSync Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Seed mock data to Firestore',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              if (_isSeeding)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                  ],
                ),
              if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSeeding ? null : _seedData,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Seed Mock Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSeeding ? null : _clearData,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Clear All Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ What will be seeded:',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 5 Artists (The Weeknd, Billie Eilish, Ed Sheeran, Taylor Swift, Drake)\n'
                      '• 5 Albums\n'
                      '• 10 Popular Songs\n\n'
                      'Note: File URLs are placeholders. You need to upload actual MP3 files to Firebase Storage.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
