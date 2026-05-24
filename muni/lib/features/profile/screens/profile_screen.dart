import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),

            const SizedBox(height: 20),

            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Cabrel'),
            ),

            const ListTile(
              leading: Icon(Icons.email),
              title: Text('cabrel@email.com'),
            ),

            const ListTile(
              leading: Icon(Icons.phone),
              title: Text('+237 6XXXXXXXX'),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),

                onPressed: () {},

                child: const Text('Déconnexion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}