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

  // ── Recherche ──────────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    actualitesFuture = ActualiteService().getActualites();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

        final all = snapshot.data ?? [];

        // ── Filtrage par titre ─────────────────────────────────────────────
        final actualites = _searchQuery.isEmpty
            ? all
            : all
                .where((a) => a.titre.toLowerCase().contains(_searchQuery))
                .toList();

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              actualitesFuture = ActualiteService().getActualites();
            });
          },
          child: CustomScrollView(
            slivers: [

              // ── BARRE DE RECHERCHE (sticky sous le menu) ─────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchBarDelegate(
                  controller: _searchController,
                  topPadding: 20,
                ),
              ),

              // ── RÉSULTATS ─────────────────────────────────────────────────
              if (actualites.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty
                              ? "Aucune actualité disponible"
                              : 'Aucun résultat pour "$_searchQuery"',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 120,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final actualite = actualites[index];

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),

                                            if (actualite.medias.isNotEmpty)
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                child: Image.network(
                                                  actualite.medias.first.fichierUrl,
                                                  height: 220,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, progress) {
                                                    if (progress == null)
                                                      return child;
                                                    return Container(
                                                      height: 220,
                                                      color:
                                                          Colors.grey.shade100,
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder:
                                                      (context, error,
                                                          stackTrace) =>
                                                          Container(
                                                    height: 220,
                                                    color: Colors.grey.shade200,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 60,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            const SizedBox(height: 20),

                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF1565C0)
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(30),
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
                                                    DateTime.parse(
                                                        actualite.createdAt),
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

                                            if (actualite.medias.length > 1)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Autres médias :",
                                                      style: TextStyle(
                                                        color:
                                                            Colors.grey.shade700,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    SizedBox(
                                                      height: 90,
                                                      child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount:
                                                            actualite.medias
                                                                    .length -
                                                                1,
                                                        itemBuilder:
                                                            (context, i) {
                                                          final media =
                                                              actualite
                                                                  .medias[i + 1];
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 10),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              child: Image.network(
                                                                media.fichierUrl,
                                                                width: 90,
                                                                height: 90,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (_,
                                                                        __,
                                                                        ___) =>
                                                                    Container(
                                                                  width: 90,
                                                                  height: 90,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200,
                                                                  child: const Icon(
                                                                      Icons
                                                                          .broken_image,
                                                                      color: Colors
                                                                          .grey),
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
                              ),
                            );
                          },

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

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: actualite.medias.isNotEmpty
                                      ? Image.network(
                                          actualite.medias.first.fichierUrl,
                                          width: 55,
                                          height: 55,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            width: 55,
                                            height: 55,
                                            color: const Color(0xFF1565C0)
                                                .withOpacity(0.12),
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
                                            color: const Color(0xFF1565C0)
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(16),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            // ✅ Titre avec highlight de la recherche
                                            child: _searchQuery.isEmpty
                                                ? Text(
                                                    actualite.titre,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : _HighlightText(
                                                    text: actualite.titre,
                                                    query: _searchQuery,
                                                  ),
                                          ),
                                          Text(
                                            DateFormat('dd/MM').format(
                                              DateTime.parse(
                                                  actualite.createdAt),
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
                      childCount: actualites.length,
                    ),
                  ),
                ),
            ],
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

          // ── MENU (toujours visible en haut à droite) ─────────────────────
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
                      MaterialPageRoute(
                          builder: (_) => const ProfileScreen()),
                    );
                  }
                  if (value == 'incident') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const IncidentScreen()),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(children: [
                      Icon(Icons.person),
                      SizedBox(width: 10),
                      Text('Profil')
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'notification',
                    child: Row(children: [
                      Icon(Icons.notifications),
                      SizedBox(width: 10),
                      Text('Notification')
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'Condultation',
                    child: Row(children: [
                      Icon(Icons.description),
                      SizedBox(width: 10),
                      Text('Consultation')
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'Permit de batir',
                    child: Row(children: [
                      Icon(Icons.home_work),
                      SizedBox(width: 10),
                      Text('Permis de bâtir')
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'e learning',
                    child: Row(children: [
                      Icon(Icons.school),
                      SizedBox(width: 10),
                      Text('E-learning')
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'payement',
                    child: Row(children: [
                      Icon(Icons.payment),
                      SizedBox(width: 10),
                      Text('Paiement')
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'Activites',
                    child: Row(children: [
                      Icon(Icons.event),
                      SizedBox(width: 10),
                      Text('Activités')
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'Aide',
                    child: Row(children: [
                      Icon(Icons.help),
                      SizedBox(width: 10),
                      Text('Aide')
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'recensement',
                    child: Row(children: [
                      Icon(Icons.people),
                      SizedBox(width: 10),
                      Text('Recensement')
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'carte interactive',
                    child: Row(children: [
                      Icon(Icons.map),
                      SizedBox(width: 10),
                      Text('Carte interactive')
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'Demander archives',
                    child: Row(children: [
                      Icon(Icons.archive),
                      SizedBox(width: 10),
                      Text('Demander archives')
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'incident',
                    child: Row(children: [
                      Icon(Icons.report_problem),
                      SizedBox(width: 10),
                      Text('Incident')
                    ]),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
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
                        color: isSelected
                            ? const Color(0xFF1565C0)
                            : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF1565C0)
                              : Colors.grey,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
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

// ── Barre de recherche sticky ──────────────────────────────────────────────────
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final double topPadding;

  const _SearchBarDelegate({
    required this.controller,
    this.topPadding = 0,
  });

  @override
  double get minExtent => topPadding + 60;

  @override
  double get maxExtent => topPadding + 60;

  @override
  bool shouldRebuild(_SearchBarDelegate old) =>
      old.controller != controller || old.topPadding != topPadding;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF5F7FB),
      padding: EdgeInsets.only(
        top: topPadding,
        left: 16,
        right: 70, // espace pour le bouton menu
        bottom: 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Rechercher une actualité...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF1565C0),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () => controller.clear(),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

// ── Widget de mise en évidence du terme recherché ──────────────────────────────
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      );
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        children: [
          if (index > 0) TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: const TextStyle(
              backgroundColor: Color(0xFFBBDEFB),
              color: Color(0xFF1565C0),
            ),
          ),
          if (index + query.length < text.length)
            TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}