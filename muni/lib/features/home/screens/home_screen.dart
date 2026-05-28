import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../consultations/screens/consultation_screen.dart';
import '../../directory/screens/directory_screen.dart';
import '../../incidents/screens/incident_screen.dart';
import '../../profile/screens/profile_screen.dart';

import '/core/api/actualite_service.dart';
import '/models/actualite_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  late Future<List<ActualiteModel>> actualitesFuture;

  @override
  void initState() {
    super.initState();
    actualitesFuture = ActualiteService().getActualites();
  }

  final List<Map<String, dynamic>> navItems = [
    {'icon': Icons.article, 'label': 'Actualités'},
    {'icon': Icons.contacts, 'label': 'Annuaire'},
    {'icon': Icons.description, 'label': 'Etat civil'},
    {'icon': Icons.dashboard, 'label': 'Dashboard'},
  ];

  Widget buildActualitesPage() {
    return FutureBuilder<List<ActualiteModel>>(
      future: actualitesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Erreur de chargement"));
        }

        final actualites = snapshot.data ?? [];

        if (actualites.isEmpty) {
          return const Center(child: Text("Aucune actualité disponible"));
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              actualitesFuture = ActualiteService().getActualites();
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: 80,
              left: 16,
              right: 16,
              bottom: 120,
            ),
            itemCount: actualites.length,
            itemBuilder: (context, index) {
              final actualite = actualites[index];

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        insetPadding: const EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),

                                    // ✅ IMAGE dans le dialog — utilise fichierUrl
                                    if (actualite.medias.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Image.network(
                                          actualite.medias.first.fichierUrl,
                                          height: 220,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, progress) {
                                            if (progress == null) return child;
                                            return Container(
                                              height: 220,
                                              color: Colors.grey.shade100,
                                              child: const Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 220,
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 60,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                    const SizedBox(height: 20),

                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1565C0).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: const Text(
                                            "ACTUALITÉ",
                                            style: TextStyle(
                                              color: Color(0xFF1565C0),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          DateFormat('dd MMM yyyy').format(
                                            DateTime.parse(actualite.createdAt),
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 18),

                                    Text(
                                      actualite.titre,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    Text(
                                      actualite.corps,
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 16,
                                        height: 1.6,
                                      ),
                                    ),

                                    // ✅ Galerie des médias supplémentaires
                                    if (actualite.medias.length > 1)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Autres médias :",
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              height: 90,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: actualite.medias.length - 1,
                                                itemBuilder: (context, i) {
                                                  final media = actualite.medias[i + 1];
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 10),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Image.network(
                                                        media.fichierUrl,
                                                        width: 90,
                                                        height: 90,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => Container(
                                                          width: 90,
                                                          height: 90,
                                                          color: Colors.grey.shade200,
                                                          child: const Icon(Icons.broken_image, color: Colors.grey),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // CLOSE BUTTON
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 22),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },

                // ✅ CARTE — affiche la vraie image au lieu de l'icône fixe
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ✅ IMAGE MINIATURE (remplace l'icône notifications)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: actualite.medias.isNotEmpty
                            ? Image.network(
                                actualite.medias.first.fichierUrl,
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 55,
                                  height: 55,
                                  color: const Color(0xFF1565C0).withOpacity(0.12),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Color(0xFF1565C0),
                                    size: 28,
                                  ),
                                ),
                              )
                            : Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1565C0).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.notifications,
                                  color: Color(0xFF1565C0),
                                  size: 30,
                                ),
                              ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    actualite.titre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  DateFormat('dd/MM').format(
                                    DateTime.parse(actualite.createdAt),
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              actualite.corps,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Appuyez pour voir plus",
                              style: TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      extendBody: true,
      body: Stack(
        children: [
          currentIndex == 0
              ? buildActualitesPage()
              : IndexedStack(
                  index: currentIndex - 1,
                  children: const [
                    DirectoryScreen(),
                    ConsultationScreen(),
                    ProfileScreen(),
                  ],
                ),

          Positioned(
            top: 20,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.menu, color: Colors.black),
                onSelected: (value) {
                  if (value == 'profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  }
                  if (value == 'incident') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const IncidentScreen()),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(children: [Icon(Icons.person), SizedBox(width: 10), Text('Profil')]),
                  ),
                  const PopupMenuItem(
                    value: 'notification',
                    child: Row(children: [Icon(Icons.notifications), SizedBox(width: 10), Text('Notification')]),
                  ),
                  const PopupMenuItem(
                    value: 'Condultation',
                    child: Row(children: [Icon(Icons.description), SizedBox(width: 10), Text('Consultation')]),
                  ),
                  const PopupMenuItem(
                    value: 'Permit de batir',
                    child: Row(children: [Icon(Icons.home_work), SizedBox(width: 10), Text('Permis de bâtir')]),
                  ),
                  const PopupMenuItem(
                    value: 'e learning',
                    child: Row(children: [Icon(Icons.school), SizedBox(width: 10), Text('E-learning')]),
                  ),
                  const PopupMenuItem(
                    value: 'payement',
                    child: Row(children: [Icon(Icons.payment), SizedBox(width: 10), Text('Paiement')]),
                  ),
                  const PopupMenuItem(
                    value: 'Activites',
                    child: Row(children: [Icon(Icons.event), SizedBox(width: 10), Text('Activités')]),
                  ),
                  const PopupMenuItem(
                    value: 'Aide',
                    child: Row(children: [Icon(Icons.help), SizedBox(width: 10), Text('Aide')]),
                  ),
                  const PopupMenuItem(
                    value: 'recensement',
                    child: Row(children: [Icon(Icons.people), SizedBox(width: 10), Text('Recensement')]),
                  ),
                  const PopupMenuItem(
                    value: 'carte interactive',
                    child: Row(children: [Icon(Icons.map), SizedBox(width: 10), Text('Carte interactive')]),
                  ),
                  const PopupMenuItem(
                    value: 'Demander archives',
                    child: Row(children: [Icon(Icons.archive), SizedBox(width: 10), Text('Demander archives')]),
                  ),
                  const PopupMenuItem(
                    value: 'incident',
                    child: Row(children: [Icon(Icons.report_problem), SizedBox(width: 10), Text('Incident')]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          height: 75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = currentIndex == index;

              return GestureDetector(
                onTap: () => setState(() => currentIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1565C0).withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'],
                        size: isSelected ? 30 : 24,
                        color: isSelected ? const Color(0xFF1565C0) : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF1565C0) : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: isSelected ? 12 : 11,
                        ),
                        child: Text(item['label']),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}