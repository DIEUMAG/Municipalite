from django.db import models

# Create your models here.
from django.db import models
import uuid


def generate_numero_acte():
    from django.utils import timezone
    year = timezone.now().year
    count = ActeNaissance.objects.filter(date_etablissement__year=year).count() + 1
    return f"ACT-{year}-{str(count).zfill(5)}"


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

    # ── Auto-generated ────────────────────────────────────────────────────────
    id_unique          = models.CharField(max_length=20, unique=True, editable=False)
    numero_acte        = models.CharField(max_length=30, unique=True, editable=False)
    date_etablissement = models.DateTimeField(auto_now_add=True)
    statut             = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')

    # ── Enfant ────────────────────────────────────────────────────────────────
    enfant_noms        = models.CharField(max_length=200)
    enfant_prenoms     = models.CharField(max_length=200)
    enfant_date_naissance = models.DateField()
    enfant_lieu_naissance = models.CharField(max_length=200)

    # ── Mère ──────────────────────────────────────────────────────────────────
    mere_noms             = models.CharField(max_length=200)
    mere_date_naissance   = models.DateField()
    mere_lieu_residence   = models.CharField(max_length=200)
    mere_duree_residence  = models.CharField(max_length=100, blank=True)
    mere_profession       = models.CharField(max_length=200, blank=True)
    mere_contact          = models.CharField(max_length=30, blank=True)
    mere_situation_matrimoniale = models.CharField(max_length=20, choices=SITUATION_CHOICES, blank=True)
    mere_niveau_scolaire  = models.CharField(max_length=20, choices=NIVEAU_CHOICES, blank=True)
    mere_nationalite      = models.CharField(max_length=100, blank=True)
    mere_cni              = models.CharField(max_length=50, blank=True)
    mere_nb_enfants       = models.PositiveIntegerField(default=0)

    # ── Père ──────────────────────────────────────────────────────────────────
    pere_noms             = models.CharField(max_length=200)
    pere_date_lieu_naissance = models.CharField(max_length=200)
    pere_domicile         = models.CharField(max_length=200, blank=True)
    pere_profession       = models.CharField(max_length=200, blank=True)
    pere_contact          = models.CharField(max_length=30, blank=True)
    pere_niveau_scolaire  = models.CharField(max_length=20, choices=NIVEAU_CHOICES, blank=True)
    pere_nationalite      = models.CharField(max_length=100, blank=True)
    pere_cni              = models.CharField(max_length=50, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table  = "requette_acte"
        ordering  = ["-created_at"]
        verbose_name = "Acte de naissance"
        verbose_name_plural = "Actes de naissance"

    def save(self, *args, **kwargs):
        if not self.id_unique:
            self.id_unique  = uuid.uuid4().hex[:8].upper()
        if not self.numero_acte:
            from django.utils import timezone
            year  = timezone.now().year
            count = ActeNaissance.objects.filter(date_etablissement__year=year).count() + 1
            self.numero_acte = f"ACT-{year}-{str(count).zfill(5)}"
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.numero_acte} — {self.enfant_noms} {self.enfant_prenoms}"


# Existing PDF-upload Acte model (unchanged)
class Acte(models.Model):
    TYPE_CHOICES = [
        ('naissance', 'Acte de naissance'),
        ('mariage',   'Acte de mariage'),
        ('deces',     'Acte de décès'),
    ]
    type_acte   = models.CharField(max_length=20, choices=TYPE_CHOICES)
    fichier     = models.FileField(upload_to='actes/')
    nom_complet = models.CharField(max_length=200, blank=True)
    description = models.TextField(blank=True)
    date_upload = models.DateTimeField(auto_now_add=True)
    updated_at  = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "requette_acte_upload"
        ordering = ["-date_upload"]

    def __str__(self):
        return f"{self.get_type_acte_display()} — {self.nom_complet or self.id}"