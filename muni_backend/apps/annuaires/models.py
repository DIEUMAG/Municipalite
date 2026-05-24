from django.db import models


class Service(models.Model):
    """
    Represents a directory category (Police, Pompiers, Hôpitaux, etc.)
    Mirrors the `annuaires` list in AnnuairesScreen.
    """
    title = models.CharField(max_length=100, unique=True)
    icon = models.CharField(max_length=100, help_text="Flutter Icons name, e.g. 'local_police'")
    color = models.CharField(max_length=20, help_text="Color name, e.g. 'blue', 'red'")

    class Meta:
        db_table = "annuaires_service"
        ordering = ["id"]

    def __str__(self):
        return self.title


class DirectoryEntry(models.Model):
    """
    A single institution/establishment in a service directory.
    Mirrors the form fields in DirectoryFormScreen.
    """
    service = models.ForeignKey(
        Service, on_delete=models.CASCADE, related_name="entries"
    )

    # --- General fields (shown for ALL services) ---
    name = models.CharField(max_length=200, verbose_name="Nom de l'établissement")
    responsible = models.CharField(max_length=200, blank=True, verbose_name="Responsable")
    phone = models.CharField(max_length=30, blank=True, verbose_name="Téléphone")
    address = models.TextField(blank=True, verbose_name="Adresse")
    email = models.EmailField(blank=True, verbose_name="Email")
    hours = models.CharField(max_length=200, blank=True, verbose_name="Horaires")
    description = models.TextField(blank=True, verbose_name="Description")

    # --- Police-specific ---
    commissariat = models.CharField(max_length=200, blank=True, verbose_name="Commissariat")
    zone_covered = models.CharField(max_length=200, blank=True, verbose_name="Zone couverte")

    # --- Pompiers-specific ---
    caserne = models.CharField(max_length=200, blank=True, verbose_name="Caserne")
    intervention_zone = models.CharField(max_length=200, blank=True, verbose_name="Zone d'intervention")

    # --- Shared: Police + Pompiers ---
    emergency_number = models.CharField(max_length=30, blank=True, verbose_name="Numéro d'urgence")

    # --- Hôpitaux-specific ---
    hospital_type = models.CharField(max_length=200, blank=True, verbose_name="Type d'hôpital")
    medical_services = models.TextField(blank=True, verbose_name="Services médicaux")
    emergency_available = models.CharField(max_length=200, blank=True, verbose_name="Urgences disponibles")

    # --- Mairie-specific ---
    mayor_name = models.CharField(max_length=200, blank=True, verbose_name="Nom du maire")
    offered_services = models.TextField(blank=True, verbose_name="Services proposés")

    # --- Services administratifs-specific ---
    service_type = models.CharField(max_length=200, blank=True, verbose_name="Type de service")
    documents_delivered = models.TextField(blank=True, verbose_name="Documents délivrés")

    # --- Éducation-specific ---
    school_name = models.CharField(max_length=200, blank=True, verbose_name="Nom de l'école")
    education_level = models.CharField(max_length=200, blank=True, verbose_name="Niveau d'enseignement")
    director = models.CharField(max_length=200, blank=True, verbose_name="Directeur")

    # --- Timestamps ---
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "annuaires_entry"
        ordering = ["-updated_at"]
        verbose_name = "Directory Entry"
        verbose_name_plural = "Directory Entries"

    def __str__(self):
        return f"{self.service.title} — {self.name}"
