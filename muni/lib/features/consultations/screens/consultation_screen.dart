import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '/core/api/requette_service.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen>
    with SingleTickerProviderStateMixin {

  final _svc = ActeNaissanceService();
  late TabController _tabs;

  String? selectedActe;
  bool _submitting = false;

  final List<String> typesActes = [
    'Acte de naissance',
    'Acte de mariage',
    'Acte de décès',
    'Concession funéraire',
  ];

  // Auto-generated (reset on each new form)
  late String _idUnique;
  late String _numeroActe;
  late String _dateEtablissement;

  // ── Enfant ─────────────────────────────────────────────────────────────────
  final _enfantNoms      = TextEditingController();
  final _enfantPrenoms   = TextEditingController();
  final _enfantDateNaiss = TextEditingController();
  final _enfantLieuNaiss = TextEditingController();
  String? _enfantSexe;                         // 'masculin' | 'feminin'
  final _enfantTypeNaissance = TextEditingController();
  final _enfantRangNaissance = TextEditingController();
  final _enfantPoids         = TextEditingController();
  final _enfantTaille        = TextEditingController();
  // Personne ayant assisté la mère (multi-select)
  final Set<String> _assistants = {};
  final List<Map<String, String>> _assistantOptions = [
    {'value': 'medecin',    'label': 'Médecin'},
    {'value': 'sage_femme', 'label': 'Sage-femme'},
    {'value': 'infirmiere', 'label': 'Infirmière'},
    {'value': 'aucune',     'label': 'Aucune'},
  ];

  // ── Mère ───────────────────────────────────────────────────────────────────
  final _mereNoms        = TextEditingController();
  final _mereDateNaiss   = TextEditingController();
  final _mereLieuResid   = TextEditingController();
  final _mereDureeResid  = TextEditingController();
  final _mereProfession  = TextEditingController();
  final _mereContact     = TextEditingController();
  final _mereNationalite = TextEditingController();
  final _mereCni         = TextEditingController();
  final _mereNbEnfants   = TextEditingController();
  final _mereNbDecesFoetal    = TextEditingController();
  final _mereDateDernierVivant = TextEditingController();
  String? _mereSituation;
  String? _mereNiveauScol;

  // ── Père ───────────────────────────────────────────────────────────────────
  final _pereNoms          = TextEditingController();
  final _pereDateLieuNaiss = TextEditingController();
  final _pereDomicile      = TextEditingController();
  final _pereProfession    = TextEditingController();
  final _pereContact       = TextEditingController();
  final _pereNiveauScol    = TextEditingController();
  String? _pereNiveauScolValue;
  final _pereNationalite   = TextEditingController();
  final _pereCni           = TextEditingController();
  final _pereNbEnfantsVivants   = TextEditingController();
  final _pereNbDecesFoetal      = TextEditingController();
  final _pereDateDernierVivant  = TextEditingController();

  // ── Déclarant ──────────────────────────────────────────────────────────────
  final _declarantNoms    = TextEditingController();
  final _declarantQualite = TextEditingController();
  final _declarantContact = TextEditingController();

  // ── Options ────────────────────────────────────────────────────────────────
  final List<Map<String, String>> _situations = [
    {'value': 'celibataire', 'label': 'Célibataire'},
    {'value': 'mariee',      'label': 'Mariée'},
    {'value': 'divorcee',    'label': 'Divorcée'},
    {'value': 'veuve',       'label': 'Veuve'},
  ];

  final List<Map<String, String>> _niveaux = [
    {'value': 'non_scolarise', 'label': 'Non scolarisé(e)'},
    {'value': 'primaire',      'label': 'Primaire'},
    {'value': 'secondaire',    'label': 'Secondaire'},
    {'value': 'superieur',     'label': 'Supérieur'},
  ];

  // ── Mes demandes ───────────────────────────────────────────────────────────
  List<ActeNaissanceModel> _mesDemandes = [];
  bool _loadingDemandes = true;
  String? _demandesError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() { if (_tabs.index == 1) _loadDemandes(); });
    _generateAutoFields();
  }

  void _generateAutoFields() {
    _idUnique          = const Uuid().v4().replaceAll('-', '').substring(0, 8).toUpperCase();
    _numeroActe        = 'ACT-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 100000}';
    _dateEtablissement = _fmt(DateTime.now());
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in [
      _enfantNoms, _enfantPrenoms, _enfantDateNaiss, _enfantLieuNaiss,
      _enfantTypeNaissance, _enfantRangNaissance, _enfantPoids, _enfantTaille,
      _mereNoms, _mereDateNaiss, _mereLieuResid, _mereDureeResid,
      _mereProfession, _mereContact, _mereNationalite, _mereCni, _mereNbEnfants,
      _mereNbDecesFoetal, _mereDateDernierVivant,
      _pereNoms, _pereDateLieuNaiss, _pereDomicile, _pereProfession,
      _pereContact, _pereNiveauScol, _pereNationalite, _pereCni,
      _pereNbEnfantsVivants, _pereNbDecesFoetal, _pereDateDernierVivant,
      _declarantNoms, _declarantQualite, _declarantContact,
    ]) { c.dispose(); }
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  Future<void> _pickDate(TextEditingController ctrl) async {
    final p = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (p != null) ctrl.text = _fmt(p);
  }

  String _toIso(String d) {
    if (d.isEmpty) return '';
    final parts = d.split('/');
    if (parts.length == 3) return '${parts[2]}-${parts[1]}-${parts[0]}';
    return d;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (selectedActe != 'Acte de naissance') {
      _snack('Seul l\'acte de naissance est disponible pour l\'instant.');
      return;
    }
    if (_enfantNoms.text.isEmpty || _mereNoms.text.isEmpty || _pereNoms.text.isEmpty) {
      _snack('Veuillez remplir au moins les noms de l\'enfant, la mère et le père.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final acte = ActeNaissanceModel(
        enfantNoms:             _enfantNoms.text.trim(),
        enfantPrenoms:          _enfantPrenoms.text.trim(),
        enfantDateNaissance:    _toIso(_enfantDateNaiss.text),
        enfantLieuNaissance:    _enfantLieuNaiss.text.trim(),
        mereNoms:               _mereNoms.text.trim(),
        mereDateNaissance:      _toIso(_mereDateNaiss.text),
        mereLieuResidence:      _mereLieuResid.text.trim(),
        mereDureeResidence:     _mereDureeResid.text.trim(),
        mereProfession:         _mereProfession.text.trim(),
        mereContact:            _mereContact.text.trim(),
        mereSituationMatrimoniale: _mereSituation ?? '',
        mereNiveauScolaire:     _mereNiveauScol ?? '',
        mereNationalite:        _mereNationalite.text.trim(),
        mereCni:                _mereCni.text.trim(),
        mereNbEnfants:          int.tryParse(_mereNbEnfants.text) ?? 0,
        pereNoms:               _pereNoms.text.trim(),
        pereDateLieuNaissance:  _pereDateLieuNaiss.text.trim(),
        pereDomicile:           _pereDomicile.text.trim(),
        pereProfession:         _pereProfession.text.trim(),
        pereContact:            _pereContact.text.trim(),
        pereNiveauScolaire:     _pereNiveauScolValue ?? '',
        pereNationalite:        _pereNationalite.text.trim(),
        pereCni:                _pereCni.text.trim(),
      );

      final saved = await _svc.soumettre(acte);
      _snack('Demande soumise ✓ — N° ${saved.numeroActe}');

      // Reset form
      setState(() {
        selectedActe = null;
        _enfantSexe = null;
        _assistants.clear();
        _mereSituation = null;
        _mereNiveauScol = null;
        _pereNiveauScolValue = null;
      });
      for (final c in [
        _enfantNoms, _enfantPrenoms, _enfantDateNaiss, _enfantLieuNaiss,
        _enfantTypeNaissance, _enfantRangNaissance, _enfantPoids, _enfantTaille,
        _mereNoms, _mereDateNaiss, _mereLieuResid, _mereDureeResid,
        _mereProfession, _mereContact, _mereNationalite, _mereCni, _mereNbEnfants,
        _mereNbDecesFoetal, _mereDateDernierVivant,
        _pereNoms, _pereDateLieuNaiss, _pereDomicile, _pereProfession,
        _pereContact, _pereNiveauScol, _pereNationalite, _pereCni,
        _pereNbEnfantsVivants, _pereNbDecesFoetal, _pereDateDernierVivant,
        _declarantNoms, _declarantQualite, _declarantContact,
      ]) { c.clear(); }
      _generateAutoFields();
      _tabs.animateTo(1);
      _loadDemandes();
    } catch (e) {
      _snack('Erreur: $e');
    } finally {
      setState(() => _submitting = false);
    }
  }

  // ── Load my requests ───────────────────────────────────────────────────────

  Future<void> _loadDemandes() async {
    setState(() { _loadingDemandes = true; _demandesError = null; });
    try {
      final data = await _svc.fetchAll();
      setState(() { _mesDemandes = data; _loadingDemandes = false; });
    } catch (e) {
      setState(() { _demandesError = e.toString(); _loadingDemandes = false; });
    }
  }

  void _snack(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Demandes d'actes"),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.edit_document), text: 'Nouvelle demande'),
            Tab(icon: Icon(Icons.list_alt),      text: 'Mes demandes'),
          ],
        ),
      ),
      bottomNavigationBar: _tabs.index == 0 && selectedActe != null
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,-2))],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                    label: Text(_submitting ? 'Envoi en cours...' : 'Soumettre la demande'),
                  ),
                ),
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabs,
        children: [_formTab(), _demandesTab()],
      ),
    );
  }

  // ── Form tab ───────────────────────────────────────────────────────────────

  Widget _formTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sélectionnez le type d'acte",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: selectedActe,
            decoration: InputDecoration(
              hintText: "Choisir un type d'acte",
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            items: typesActes.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
            onChanged: (v) => setState(() => selectedActe = v),
          ),
          const SizedBox(height: 25),
          if (selectedActe == 'Acte de naissance') _naissanceForm(),
          if (selectedActe == 'Acte de mariage')
            _comingSoon('Acte de mariage', Colors.pink, Icons.favorite),
          if (selectedActe == 'Acte de décès')
            _comingSoon("Acte de décès", Colors.grey.shade700, Icons.person_off),
          if (selectedActe == 'Concession funéraire')
            _comingSoon('Concession funéraire', Colors.brown, Icons.landscape),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _comingSoon(String title, Color color, IconData icon) {
    return _card(title, color, icon, [
      const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Ce type d\'acte sera disponible prochainement.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey)),
        ),
      ),
    ]);
  }

  // ── Mes demandes tab ───────────────────────────────────────────────────────

  Widget _demandesTab() {
    if (_loadingDemandes) return const Center(child: CircularProgressIndicator());
    if (_demandesError != null) return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        Text(_demandesError!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _loadDemandes, child: const Text('Réessayer')),
      ]),
    );
    if (_mesDemandes.isEmpty) return const Center(
      child: Text('Aucune demande soumise pour l\'instant.'),
    );
    return RefreshIndicator(
      onRefresh: _loadDemandes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mesDemandes.length,
        itemBuilder: (_, i) => _demandeCard(_mesDemandes[i]),
      ),
    );
  }

  Widget _demandeCard(ActeNaissanceModel acte) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.child_care, color: Colors.blue, size: 26),
          ),
          title: Text(
            '${acte.enfantNoms} ${acte.enfantPrenoms}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(acte.numeroActe,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text(acte.formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: acte.statutColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  acte.statutDisplay,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: acte.statutColor),
                ),
              ),
            ],
          ),
          onTap: () => _showDetail(acte),
        ),
      ),
    );
  }

  // ── Detail bottom sheet ────────────────────────────────────────────────────

  void _showDetail(ActeNaissanceModel acte) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              )),
              Row(children: [
                const Icon(Icons.child_care, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                Expanded(child: Text('Acte de naissance',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: acte.statutColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(acte.statutDisplay,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: acte.statutColor, fontSize: 12)),
                ),
              ]),
              const SizedBox(height: 20),
              _detailSection('Informations administratives', Colors.blueGrey, Icons.admin_panel_settings, [
                _row('ID Unique',        acte.idUnique),
                _row('Numéro d\'acte',   acte.numeroActe),
                _row('Date d\'établissement', acte.formattedDate),
              ]),
              const SizedBox(height: 14),
              _detailSection('Enfant', Colors.green, Icons.child_care, [
                _row('Noms',             acte.enfantNoms),
                _row('Prénoms',          acte.enfantPrenoms),
                _row('Date de naissance',acte.enfantDateNaissance),
                _row('Lieu de naissance',acte.enfantLieuNaissance),
              ]),
              const SizedBox(height: 14),
              _detailSection('Mère', Colors.pink, Icons.woman, [
                _row('Noms et prénoms',  acte.mereNoms),
                _row('Date de naissance',acte.mereDateNaissance),
                _row('Lieu de résidence',acte.mereLieuResidence),
                if (acte.mereDureeResidence.isNotEmpty)
                  _row('Durée de résidence', acte.mereDureeResidence),
                if (acte.mereProfession.isNotEmpty)
                  _row('Profession', acte.mereProfession),
                if (acte.mereContact.isNotEmpty)
                  _row('Contact', acte.mereContact),
                if (acte.mereSituationDisplay.isNotEmpty)
                  _row('Situation matrimoniale', acte.mereSituationDisplay),
                if (acte.mereNiveauDisplay.isNotEmpty)
                  _row('Niveau de scolarité', acte.mereNiveauDisplay),
                if (acte.mereNationalite.isNotEmpty)
                  _row('Nationalité', acte.mereNationalite),
                if (acte.mereCni.isNotEmpty)
                  _row('Numéro CNI', acte.mereCni),
                _row('Nombre d\'enfants', '${acte.mereNbEnfants}'),
              ]),
              const SizedBox(height: 14),
              _detailSection('Père', Colors.indigo, Icons.man, [
                _row('Noms et prénoms',  acte.pereNoms),
                if (acte.pereDateLieuNaissance.isNotEmpty)
                  _row('Date et lieu de naissance', acte.pereDateLieuNaissance),
                if (acte.pereDomicile.isNotEmpty)
                  _row('Domicile', acte.pereDomicile),
                if (acte.pereProfession.isNotEmpty)
                  _row('Profession', acte.pereProfession),
                if (acte.pereContact.isNotEmpty)
                  _row('Contact', acte.pereContact),
                if (acte.pereNiveauDisplay.isNotEmpty)
                  _row('Niveau de scolarité', acte.pereNiveauDisplay),
                if (acte.pereNationalite.isNotEmpty)
                  _row('Nationalité', acte.pereNationalite),
                if (acte.pereCni.isNotEmpty)
                  _row('Numéro CNI', acte.pereCni),
              ]),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailSection(String title, Color color, IconData icon, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          ]),
          const Divider(height: 16),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: TextStyle(
                fontSize: 12, color: Colors.grey.shade600)),
          ),
          Expanded(child: Text(value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // ── Naissance form ─────────────────────────────────────────────────────────

  Widget _naissanceForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ── Section admin ──────────────────────────────────────────────────────
      _card('Informations administratives', Colors.blueGrey, Icons.admin_panel_settings, [
        _auto('ID Unique',          _idUnique,          Icons.fingerprint),
        const SizedBox(height: 12),
        _auto("Numéro d'acte",      _numeroActe,        Icons.confirmation_number),
        const SizedBox(height: 12),
        _auto("Date d'établissement", _dateEtablissement, Icons.calendar_today),
      ]),
      const SizedBox(height: 16),

      // ── Section 1 : Enfant ─────────────────────────────────────────────────
      _card("1. Informations sur l'enfant", Colors.green, Icons.child_care, [
        _f('Noms *',           Icons.person,         _enfantNoms),
        const SizedBox(height: 12),
        _f('Prénoms',          Icons.person_outline,  _enfantPrenoms),
        const SizedBox(height: 12),
        _dp('Date de naissance', Icons.cake,           _enfantDateNaiss),
        const SizedBox(height: 12),
        _f('Lieu de naissance', Icons.location_on,    _enfantLieuNaiss),
        const SizedBox(height: 18),

        // Sexe
        const Text('Sexe *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: RadioListTile<String>(
              dense: true,
              title: const Text('Masculin', style: TextStyle(fontSize: 13)),
              value: 'masculin',
              groupValue: _enfantSexe,
              onChanged: (v) => setState(() => _enfantSexe = v),
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              dense: true,
              title: const Text('Féminin', style: TextStyle(fontSize: 13)),
              value: 'feminin',
              groupValue: _enfantSexe,
              onChanged: (v) => setState(() => _enfantSexe = v),
            ),
          ),
        ]),
        const SizedBox(height: 12),

        _f('Type de naissance', Icons.family_restroom, _enfantTypeNaissance),
        const SizedBox(height: 12),
        _f('Rang de naissance', Icons.format_list_numbered, _enfantRangNaissance,
            kb: TextInputType.number),
        const SizedBox(height: 12),
        _f('Poids de l\'enfant (kg)', Icons.monitor_weight, _enfantPoids,
            kb: TextInputType.numberWithOptions(decimal: true)),
        const SizedBox(height: 12),
        _f('Taille de l\'enfant (cm)', Icons.height, _enfantTaille,
            kb: TextInputType.numberWithOptions(decimal: true)),
        const SizedBox(height: 18),

        // Personne ayant assisté la mère
        const Text('Personne ayant assisté la mère',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Wrap(
          children: _assistantOptions.map((a) => SizedBox(
            width: 180,
            child: CheckboxListTile(
              dense: true,
              title: Text(a['label']!, style: const TextStyle(fontSize: 13)),
              value: _assistants.contains(a['value']),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    // "Aucune" is exclusive
                    if (a['value'] == 'aucune') {
                      _assistants.clear();
                    } else {
                      _assistants.remove('aucune');
                    }
                    _assistants.add(a['value']!);
                  } else {
                    _assistants.remove(a['value']);
                  }
                });
              },
            ),
          )).toList(),
        ),
      ]),
      const SizedBox(height: 16),

      // ── Section 2 : Mère ───────────────────────────────────────────────────
      _card("2. Informations sur la mère", Colors.pink, Icons.woman, [
        _f('Noms et prénoms *', Icons.person,         _mereNoms),
        const SizedBox(height: 12),
        _dp('Date de naissance', Icons.cake,           _mereDateNaiss),
        const SizedBox(height: 12),
        _f('Lieu de résidence *', Icons.home,          _mereLieuResid),
        const SizedBox(height: 12),
        _f('Durée de résidence', Icons.timer,          _mereDureeResid),
        const SizedBox(height: 12),
        _f('Profession',        Icons.work,            _mereProfession),
        const SizedBox(height: 12),
        _f('Contact',           Icons.phone,           _mereContact),
        const SizedBox(height: 12),
        _f('Nationalité',       Icons.flag,            _mereNationalite),
        const SizedBox(height: 12),
        _f('Numéro de CNI',     Icons.credit_card,     _mereCni),
        const SizedBox(height: 12),
        _f("Nombre d'enfants",  Icons.people,          _mereNbEnfants,
            kb: TextInputType.number),
        const SizedBox(height: 12),
        _f('Nombre de décès fœtaux', Icons.crisis_alert, _mereNbDecesFoetal,
            kb: TextInputType.number),
        const SizedBox(height: 12),
        _dp('Date du dernier né vivant', Icons.event_available, _mereDateDernierVivant),
        const SizedBox(height: 18),

        // Situation matrimoniale
        const Text('Situation matrimoniale',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Wrap(
          children: _situations.map((s) => SizedBox(
            width: 160,
            child: RadioListTile<String>(
              dense: true,
              title: Text(s['label']!, style: const TextStyle(fontSize: 13)),
              value: s['value']!,
              groupValue: _mereSituation,
              onChanged: (v) => setState(() => _mereSituation = v),
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),

        // Niveau de scolarité mère
        const Text('Niveau de scolarité',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        ..._niveaux.map((n) => RadioListTile<String>(
          dense: true,
          title: Text(n['label']!, style: const TextStyle(fontSize: 13)),
          value: n['value']!,
          groupValue: _mereNiveauScol,
          onChanged: (v) => setState(() => _mereNiveauScol = v),
        )),
      ]),
      const SizedBox(height: 16),

      // ── Section 3 : Père ───────────────────────────────────────────────────
      _card("3. Informations sur le père", Colors.indigo, Icons.man, [
        _f('Noms et prénoms *',      Icons.person,      _pereNoms),
        const SizedBox(height: 12),
        _f('Date et lieu de naissance', Icons.cake,     _pereDateLieuNaiss),
        const SizedBox(height: 12),
        _f('Lieu de domicile',       Icons.home,        _pereDomicile),
        const SizedBox(height: 12),
        _f('Profession',             Icons.work,        _pereProfession),
        const SizedBox(height: 12),
        _f('Contact',                Icons.phone,       _pereContact),
        const SizedBox(height: 12),
        _f('Nationalité',            Icons.flag,        _pereNationalite),
        const SizedBox(height: 12),
        _f('Numéro de CNI',          Icons.credit_card, _pereCni),
        const SizedBox(height: 12),
        _f('Nombre d\'enfants vivants', Icons.people,   _pereNbEnfantsVivants,
            kb: TextInputType.number),
        const SizedBox(height: 12),
        _f('Nombre de décès fœtaux', Icons.crisis_alert, _pereNbDecesFoetal,
            kb: TextInputType.number),
        const SizedBox(height: 12),
        _dp('Date du dernier né vivant', Icons.event_available, _pereDateDernierVivant),
        const SizedBox(height: 16),

        // Niveau de scolarité père
        const Text('Niveau de scolarité',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        ..._niveaux.map((n) => RadioListTile<String>(
          dense: true,
          title: Text(n['label']!, style: const TextStyle(fontSize: 13)),
          value: n['value']!,
          groupValue: _pereNiveauScolValue,
          onChanged: (v) => setState(() => _pereNiveauScolValue = v),
        )),
      ]),
      const SizedBox(height: 16),

      // ── Section 4 : Déclarant ──────────────────────────────────────────────
      _card("4. Informations sur le déclarant", Colors.orange, Icons.assignment_ind, [
        _f('Noms et prénoms *', Icons.person,    _declarantNoms),
        const SizedBox(height: 12),
        _f('Qualité / Statut *', Icons.badge,    _declarantQualite),
        const SizedBox(height: 12),
        _f('Contact',            Icons.phone,    _declarantContact),
      ]),
      const SizedBox(height: 16),

      // ── Section 5 : Accusé de réception (BLOQUÉE) ─────────────────────────
      _lockedCard(),
    ],
  );

  // ── Section 5 bloquée ──────────────────────────────────────────────────────

  Widget _lockedCard() {
    return Stack(
      children: [
        // Card with greyed-out fields
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.gavel, color: Colors.red.shade700, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "5. Accusé de réception de l'officier d'état civil",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 12, color: Colors.red.shade600),
                        const SizedBox(width: 4),
                        Text('Réservé à l\'officier',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade600)),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade700, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Cette section est réservée à l\'officier d\'état civil. Elle ne peut pas être remplie par le citoyen.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
                _lockedField("Noms et prénoms de l'officier", Icons.person),
                const SizedBox(height: 12),
                _lockedField("Qualité / Statut", Icons.badge),
                const SizedBox(height: 12),
                _lockedField("Centre d'état civil", Icons.account_balance),
                const SizedBox(height: 12),
                _lockedField("Date", Icons.calendar_today),
                const SizedBox(height: 12),
                _lockedField("Signature", Icons.draw),
              ],
            ),
          ),
        ),
        // Full overlay to block all interactions
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(color: Colors.white.withOpacity(0.55)),
          ),
        ),
        // Lock icon in center
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.red.shade200,
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'Section réservée à l\'officier',
                  style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _lockedField(String label, IconData icon) {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        suffixIcon: Icon(Icons.lock, size: 16, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade100,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  Widget _card(String title, Color color, IconData icon, List<Widget> children) =>
    Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );

  Widget _auto(String label, String value, IconData icon) => TextField(
    readOnly: true,
    controller: TextEditingController(text: value),
    style: const TextStyle(color: Colors.grey),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
      filled: true, fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
  );

  Widget _f(String label, IconData icon, TextEditingController ctrl,
      {TextInputType kb = TextInputType.text}) =>
    TextField(
      controller: ctrl, keyboardType: kb,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );

  Widget _dp(String label, IconData icon, TextEditingController ctrl) =>
    TextField(
      controller: ctrl, readOnly: true,
      onTap: () => _pickDate(ctrl),
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon),
        suffixIcon: const Icon(Icons.calendar_month),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
}