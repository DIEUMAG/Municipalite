from django.db import models
import uuid


class Acte(models.Model):

    TYPE_CHOICES = [
        ('naissance', 'Acte de naissance'),
        ('mariage',   'Acte de mariage'),
        ('deces',     'Acte de décès'),
    ]

    type_acte   = models.CharField(max_length=20, choices=TYPE_CHOICES, verbose_name="Type d'acte")
    fichier     = models.FileField(upload_to='actes/', verbose_name="Fichier PDF")
    nom_complet = models.CharField(max_length=200, blank=True, verbose_name="Nom complet concerné")
    description = models.TextField(blank=True, verbose_name="Description")
    date_upload = models.DateTimeField(auto_now_add=True, verbose_name="Date d'ajout")
    updated_at  = models.DateTimeField(auto_now=True)

    class Meta:
        db_table        = "etat_civil_acte"
        ordering        = ["-date_upload"]
        verbose_name    = "Acte"
        verbose_name_plural = "Actes"

    def __str__(self):
        return f"{self.get_type_acte_display()} — {self.nom_complet or self.id}"


class ActeNaissance(models.Model):

    NIVEAU_CHOICES = [
        ('non_scolarise', 'Non scolarisé(e)'),
        ('primaire',      'Primaire'),
        ('secondaire',    'Secondaire'),
        ('superieur',     'Supérieur'),
    ]
    SITUATION_CHOICES = [
        ('celibataire', 'Célibataire'),
        ('mariee',      'Mariée'),
        ('divorcee',    'Divorcée'),
        ('veuve',       'Veuve'),
    ]
    STATUT_CHOICES = [
        ('en_attente', 'En attente'),
        ('validee',    'Validée'),
        ('rejetee',    'Rejetée'),
    ]
    SEXE_CHOICES = [
        ('masculin', 'Masculin'),
        ('feminin',  'Féminin'),
    ]
    ASSISTANT_CHOICES = [
        ('medecin',    'Médecin'),
        ('sage_femme', 'Sage-femme'),
        ('infirmiere', 'Infirmière'),
        ('aucune',     'Aucune'),
    ]

    # ── Auto-generated ────────────────────────────────────────────────────────
    id_unique          = models.CharField(max_length=20, unique=True, editable=False)
    numero_acte        = models.CharField(max_length=30, unique=True, editable=False)
    date_etablissement = models.DateTimeField(auto_now_add=True)
    statut             = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')

    # ── Enfant ────────────────────────────────────────────────────────────────
    enfant_noms           = models.CharField(max_length=200)
    enfant_prenoms        = models.CharField(max_length=200, blank=True)
    enfant_date_naissance = models.DateField()
    enfant_lieu_naissance = models.CharField(max_length=200)
    enfant_sexe           = models.CharField(max_length=10, choices=SEXE_CHOICES, blank=True)
    enfant_type_naissance = models.CharField(max_length=100, blank=True,
                                             verbose_name="Type de naissance")
    enfant_rang_naissance = models.PositiveIntegerField(null=True, blank=True,
                                                        verbose_name="Rang de naissance")
    enfant_poids          = models.DecimalField(max_digits=5, decimal_places=2,
                                                null=True, blank=True,
                                                verbose_name="Poids (kg)")
    enfant_taille         = models.DecimalField(max_digits=5, decimal_places=2,
                                                null=True, blank=True,
                                                verbose_name="Taille (cm)")
    # Personne(s) ayant assisté la mère — stockées en texte séparé par virgules
    # ex: "medecin,sage_femme"  ou  "aucune"
    enfant_assistant_naissance = models.CharField(max_length=100, blank=True,
                                                  verbose_name="Personne ayant assisté la mère")

    # ── Mère ──────────────────────────────────────────────────────────────────
    mere_noms                   = models.CharField(max_length=200)
    mere_date_naissance         = models.DateField()
    mere_lieu_residence         = models.CharField(max_length=200)
    mere_duree_residence        = models.CharField(max_length=100, blank=True)
    mere_profession             = models.CharField(max_length=200, blank=True)
    mere_contact                = models.CharField(max_length=30, blank=True)
    mere_situation_matrimoniale = models.CharField(max_length=20, choices=SITUATION_CHOICES, blank=True)
    mere_niveau_scolaire        = models.CharField(max_length=20, choices=NIVEAU_CHOICES, blank=True)
    mere_nationalite            = models.CharField(max_length=100, blank=True)
    mere_cni                    = models.CharField(max_length=50, blank=True)
    mere_nb_enfants             = models.PositiveIntegerField(default=0)
    mere_nb_deces_foetal        = models.PositiveIntegerField(default=0,
                                                              verbose_name="Nombre de décès fœtaux")
    mere_date_dernier_vivant    = models.DateField(null=True, blank=True,
                                                   verbose_name="Date du dernier né vivant")

    # ── Père ──────────────────────────────────────────────────────────────────
    pere_noms                = models.CharField(max_length=200)
    pere_date_lieu_naissance = models.CharField(max_length=200, blank=True)
    pere_domicile            = models.CharField(max_length=200, blank=True)
    pere_profession          = models.CharField(max_length=200, blank=True)
    pere_contact             = models.CharField(max_length=30, blank=True)
    pere_niveau_scolaire     = models.CharField(max_length=20, choices=NIVEAU_CHOICES, blank=True)
    pere_nationalite         = models.CharField(max_length=100, blank=True)
    pere_cni                 = models.CharField(max_length=50, blank=True)
    pere_nb_enfants_vivants  = models.PositiveIntegerField(default=0,
                                                           verbose_name="Nombre d'enfants vivants")
    pere_nb_deces_foetal     = models.PositiveIntegerField(default=0,
                                                           verbose_name="Nombre de décès fœtaux")
    pere_date_dernier_vivant = models.DateField(null=True, blank=True,
                                                verbose_name="Date du dernier né vivant")

    # ── Déclarant ─────────────────────────────────────────────────────────────
    declarant_noms    = models.CharField(max_length=200, blank=True,
                                         verbose_name="Noms et prénoms du déclarant")
    declarant_qualite = models.CharField(max_length=200, blank=True,
                                         verbose_name="Qualité / Statut du déclarant")
    declarant_contact = models.CharField(max_length=30, blank=True,
                                         verbose_name="Contact du déclarant")

    # ── Accusé de réception (réservé à l'officier) ───────────────────────────
    officier_noms         = models.CharField(max_length=200, blank=True,
                                              verbose_name="Noms et prénoms de l'officier")
    officier_qualite      = models.CharField(max_length=200, blank=True,
                                              verbose_name="Qualité / Statut de l'officier")
    officier_centre       = models.CharField(max_length=200, blank=True,
                                              verbose_name="Centre d'état civil")
    officier_date         = models.DateField(null=True, blank=True,
                                              verbose_name="Date de réception")
    officier_signature    = models.CharField(max_length=200, blank=True,
                                              verbose_name="Signature (référence)")

    # ── Timestamps ────────────────────────────────────────────────────────────
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table        = "etat_civil_acte_naissance"
        ordering        = ["-created_at"]
        verbose_name    = "Acte de naissance"
        verbose_name_plural = "Actes de naissance"

    def save(self, *args, **kwargs):
        if not self.id_unique:
            self.id_unique = uuid.uuid4().hex[:8].upper()
        if not self.numero_acte:
            from django.utils import timezone
            year  = timezone.now().year
            count = ActeNaissance.objects.filter(date_etablissement__year=year).count() + 1
            self.numero_acte = f"ACT-{year}-{str(count).zfill(5)}"
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.numero_acte} — {self.enfant_noms} {self.enfant_prenoms}"

    # Helpers pour l'affichage des assistants (champ CSV)
    def get_assistants_list(self):
        if not self.enfant_assistant_naissance:
            return []
        return self.enfant_assistant_naissance.split(',')

    def get_assistants_display(self):
        labels = {
            'medecin':    'Médecin',
            'sage_femme': 'Sage-femme',
            'infirmiere': 'Infirmière',
            'aucune':     'Aucune',
        }
        return ', '.join(labels.get(a, a) for a in self.get_assistants_list())