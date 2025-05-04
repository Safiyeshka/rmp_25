import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class SecondScreen extends StatelessWidget {
  final String text;

  const SecondScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.secondScreen),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.text_snippet, size: 64, color: Colors.lightBlueAccent),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.blueGrey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.edit_note, color: Colors.white70, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '${loc.youEntered}:\n$text',
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
