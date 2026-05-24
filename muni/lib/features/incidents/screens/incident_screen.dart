import 'package:flutter/material.dart';

class IncidentScreen extends StatelessWidget {
  const IncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signaler un incident'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Type d’incident',
                prefixIcon: const Icon(Icons.warning),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              maxLines: 5,

              decoration: InputDecoration(
                hintText: 'Description',
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {},

                child: const Text('Envoyer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}