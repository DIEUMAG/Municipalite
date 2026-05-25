import 'package:flutter/material.dart' show Color;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class ActeNaissanceModel {
  final int? id;
  final String idUnique;
  final String numeroActe;
  final String dateEtablissement;
  final String statut;
  final String statutDisplay;

  // Enfant
  final String enfantNoms;
  final String enfantPrenoms;
  final String enfantDateNaissance;
  final String enfantLieuNaissance;

  // Mère
  final String mereNoms;
  final String mereDateNaissance;
  final String mereLieuResidence;
  final String mereDureeResidence;
  final String mereProfession;
  final String mereContact;
  final String mereSituationMatrimoniale;
  final String mereSituationDisplay;
  final String mereNiveauScolaire;
  final String mereNiveauDisplay;
  final String mereNationalite;
  final String mereCni;
  final int mereNbEnfants;

  // Père
  final String pereNoms;
  final String pereDateLieuNaissance;
  final String pereDomicile;
  final String pereProfession;
  final String pereContact;
  final String pereNiveauScolaire;
  final String pereNiveauDisplay;
  final String pereNationalite;
  final String pereCni;

  const ActeNaissanceModel({
    this.id,
    this.idUnique = '',
    this.numeroActe = '',
    this.dateEtablissement = '',
    this.statut = 'en_attente',
    this.statutDisplay = 'En attente',
    required this.enfantNoms,
    required this.enfantPrenoms,
    required this.enfantDateNaissance,
    required this.enfantLieuNaissance,
    required this.mereNoms,
    required this.mereDateNaissance,
    required this.mereLieuResidence,
    this.mereDureeResidence = '',
    this.mereProfession = '',
    this.mereContact = '',
    this.mereSituationMatrimoniale = '',
    this.mereSituationDisplay = '',
    this.mereNiveauScolaire = '',
    this.mereNiveauDisplay = '',
    this.mereNationalite = '',
    this.mereCni = '',
    this.mereNbEnfants = 0,
    required this.pereNoms,
    required this.pereDateLieuNaissance,
    this.pereDomicile = '',
    this.pereProfession = '',
    this.pereContact = '',
    this.pereNiveauScolaire = '',
    this.pereNiveauDisplay = '',
    this.pereNationalite = '',
    this.pereCni = '',
  });

  factory ActeNaissanceModel.fromJson(Map<String, dynamic> j) =>
      ActeNaissanceModel(
        id: j['id'],
        idUnique: j['id_unique'] ?? '',
        numeroActe: j['numero_acte'] ?? '',
        dateEtablissement: j['date_etablissement'] ?? '',
        statut: j['statut'] ?? 'en_attente',
        statutDisplay: j['statut_display'] ?? '',
        enfantNoms: j['enfant_noms'] ?? '',
        enfantPrenoms: j['enfant_prenoms'] ?? '',
        enfantDateNaissance: j['enfant_date_naissance'] ?? '',
        enfantLieuNaissance: j['enfant_lieu_naissance'] ?? '',
        mereNoms: j['mere_noms'] ?? '',
        mereDateNaissance: j['mere_date_naissance'] ?? '',
        mereLieuResidence: j['mere_lieu_residence'] ?? '',
        mereDureeResidence: j['mere_duree_residence'] ?? '',
        mereProfession: j['mere_profession'] ?? '',
        mereContact: j['mere_contact'] ?? '',
        mereSituationMatrimoniale: j['mere_situation_matrimoniale'] ?? '',
        mereSituationDisplay: j['mere_situation_display'] ?? '',
        mereNiveauScolaire: j['mere_niveau_scolaire'] ?? '',
        mereNiveauDisplay: j['mere_niveau_display'] ?? '',
        mereNationalite: j['mere_nationalite'] ?? '',
        mereCni: j['mere_cni'] ?? '',
        mereNbEnfants: j['mere_nb_enfants'] ?? 0,
        pereNoms: j['pere_noms'] ?? '',
        pereDateLieuNaissance: j['pere_date_lieu_naissance'] ?? '',
        pereDomicile: j['pere_domicile'] ?? '',
        pereProfession: j['pere_profession'] ?? '',
        pereContact: j['pere_contact'] ?? '',
        pereNiveauScolaire: j['pere_niveau_scolaire'] ?? '',
        pereNiveauDisplay: j['pere_niveau_display'] ?? '',
        pereNationalite: j['pere_nationalite'] ?? '',
        pereCni: j['pere_cni'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'enfant_noms': enfantNoms,
        'enfant_prenoms': enfantPrenoms,
        'enfant_date_naissance': enfantDateNaissance,
        'enfant_lieu_naissance': enfantLieuNaissance,
        'mere_noms': mereNoms,
        'mere_date_naissance': mereDateNaissance,
        'mere_lieu_residence': mereLieuResidence,
        'mere_duree_residence': mereDureeResidence,
        'mere_profession': mereProfession,
        'mere_contact': mereContact,
        'mere_situation_matrimoniale': mereSituationMatrimoniale,
        'mere_niveau_scolaire': mereNiveauScolaire,
        'mere_nationalite': mereNationalite,
        'mere_cni': mereCni,
        'mere_nb_enfants': mereNbEnfants,
        'pere_noms': pereNoms,
        'pere_date_lieu_naissance': pereDateLieuNaissance,
        'pere_domicile': pereDomicile,
        'pere_profession': pereProfession,
        'pere_contact': pereContact,
        'pere_niveau_scolaire': pereNiveauScolaire,
        'pere_nationalite': pereNationalite,
        'pere_cni': pereCni,
      };

  String get formattedDate => dateEtablissement.isNotEmpty
      ? dateEtablissement.substring(0, 10) : '';

  Color get statutColor {
    switch (statut) {
      case 'validee':    return const Color(0xFF2E7D32);
      case 'rejetee':    return const Color(0xFFC62828);
      default:           return const Color(0xFFF57F17);
    }
  }
}

// ignore: depend_on_referenced_packages


// ─── Service ──────────────────────────────────────────────────────────────────

class ActeNaissanceService {
  final http.Client _client;
  ActeNaissanceService({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  List _parse(dynamic body) {
    if (body is Map) return body['results'] ?? [];
    if (body is List) return body;
    return [];
  }

  /// POST /api/actes-naissance/
  Future<ActeNaissanceModel> soumettre(ActeNaissanceModel acte) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/api/actes-naissance/'),
      headers: _headers,
      body: jsonEncode(acte.toJson()),
    );
    _check(response);
    return ActeNaissanceModel.fromJson(jsonDecode(response.body));
  }

  /// GET /api/actes-naissance/
  Future<List<ActeNaissanceModel>> fetchAll() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/api/actes-naissance/'),
      headers: _headers,
    );
    _check(response);
    return _parse(jsonDecode(response.body))
        .map((j) => ActeNaissanceModel.fromJson(j))
        .toList();
  }

  /// GET /api/actes-naissance/{id}/
  Future<ActeNaissanceModel> fetchOne(int id) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/api/actes-naissance/$id/'),
      headers: _headers,
    );
    _check(response);
    return ActeNaissanceModel.fromJson(jsonDecode(response.body));
  }

  void _check(http.Response r) {
    if (r.statusCode >= 400) {
      throw Exception('API ${r.statusCode}: ${r.body}');
    }
  }
}