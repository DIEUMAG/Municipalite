import 'package:flutter/material.dart';
import '/core/api/annuaires_service.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _api = AnnuairesApiService();

  List<ServiceModel> _services = [];
  final Map<int, List<DirectoryEntry>> _entries = {};
  final Set<int> _loadingEntries = {};
  bool _loadingServices = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final services = await _api.fetchServices();
      setState(() {
        _services = services;
        _loadingServices = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingServices = false;
      });
    }
  }

  Future<void> _loadEntries(int serviceId) async {
    if (_entries.containsKey(serviceId)) return;
    setState(() => _loadingEntries.add(serviceId));
    try {
      final entries = await _api.fetchEntriesByService(serviceId);
      setState(() {
        _entries[serviceId] = entries;
        _loadingEntries.remove(serviceId);
      });
    } catch (e) {
      setState(() {
        _entries[serviceId] = [];
        _loadingEntries.remove(serviceId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Annuaire"),
      ),
      body: _loadingServices
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadingServices = true;
                            _error = null;
                          });
                          _loadServices();
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _loadingServices = true;
                      _entries.clear();
                    });
                    await _loadServices();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return _ServiceCard(
                        service: service,
                        entries: _entries[service.id],
                        isLoadingEntries:
                            _loadingEntries.contains(service.id),
                        onExpanded: () => _loadEntries(service.id),
                      );
                    },
                  ),
                ),
    );
  }
}

// ─── Service card (mirrors admin card style) ─────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final List<DirectoryEntry>? entries;
  final bool isLoadingEntries;
  final VoidCallback onExpanded;

  const _ServiceCard({
    required this.service,
    required this.entries,
    required this.isLoadingEntries,
    required this.onExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Theme(
          // remove the default ExpansionTile divider
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(16),
            childrenPadding: EdgeInsets.zero,
            onExpansionChanged: (expanded) {
              if (expanded) onExpanded();
            },
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: service.flutterColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                service.flutterIcon,
                color: service.flutterColor,
                size: 30,
              ),
            ),
            title: Text(
              service.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                service.entryCount == 0
                    ? "Aucun établissement"
                    : "${service.entryCount} établissement(s)",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
            children: [
              const Divider(height: 1),
              if (isLoadingEntries)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (entries == null || entries!.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey.shade400),
                      const SizedBox(width: 10),
                      Text(
                        "Aucun établissement enregistré",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              else
                ...entries!.map(
                  (entry) => _EntryCard(entry: entry, color: service.flutterColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Entry detail card ────────────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  final DirectoryEntry entry;
  final Color color;

  const _EntryCard({required this.entry, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            entry.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Responsible
          if (entry.responsible.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.person, entry.responsible),
          ],

          // Phone
          if (entry.phone.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.phone, entry.phone, color: Colors.green.shade700),
          ],

          // Emergency number
          if (entry.emergencyNumber.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.emergency, entry.emergencyNumber,
                color: Colors.red.shade700),
          ],

          // Address
          if (entry.address.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.location_on, entry.address),
          ],

          // Email
          if (entry.email.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.email, entry.email),
          ],

          // Hours
          if (entry.hours.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.access_time, entry.hours),
          ],

          // Description
          if (entry.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.description, entry.description),
          ],

          // ── Service-specific fields ──────────────────────────────────────

          // Police
          if (entry.commissariat.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.local_police, entry.commissariat),
          ],
          if (entry.zoneCovered.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.map, "Zone: ${entry.zoneCovered}"),
          ],

          // Pompiers
          if (entry.caserne.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.fire_truck, entry.caserne),
          ],
          if (entry.interventionZone.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.location_city, "Zone: ${entry.interventionZone}"),
          ],

          // Hôpitaux
          if (entry.hospitalType.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.local_hospital, entry.hospitalType),
          ],
          if (entry.medicalServices.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.medical_services, entry.medicalServices),
          ],
          if (entry.emergencyAvailable.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.emergency, entry.emergencyAvailable,
                color: Colors.red.shade700),
          ],

          // Mairie
          if (entry.mayorName.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.account_balance, "Maire: ${entry.mayorName}"),
          ],
          if (entry.offeredServices.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.miscellaneous_services, entry.offeredServices),
          ],

          // Services administratifs
          if (entry.serviceType.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.badge, entry.serviceType),
          ],
          if (entry.documentsDelivered.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.folder, entry.documentsDelivered),
          ],

          // Éducation
          if (entry.schoolName.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.school, entry.schoolName),
          ],
          if (entry.educationLevel.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.menu_book, entry.educationLevel),
          ],
          if (entry.director.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.person_3, "Directeur: ${entry.director}"),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color ?? Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}