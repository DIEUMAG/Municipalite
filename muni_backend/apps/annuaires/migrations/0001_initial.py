from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Service",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("title", models.CharField(max_length=100, unique=True)),
                ("icon", models.CharField(help_text="Flutter Icons name, e.g. 'local_police'", max_length=100)),
                ("color", models.CharField(help_text="Color name, e.g. 'blue', 'red'", max_length=20)),
            ],
            options={"db_table": "annuaires_service", "ordering": ["id"]},
        ),
        migrations.CreateModel(
            name="DirectoryEntry",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("service", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="entries", to="annuaires.service")),
                ("name", models.CharField(max_length=200, verbose_name="Nom de l'établissement")),
                ("responsible", models.CharField(blank=True, max_length=200, verbose_name="Responsable")),
                ("phone", models.CharField(blank=True, max_length=30, verbose_name="Téléphone")),
                ("address", models.TextField(blank=True, verbose_name="Adresse")),
                ("email", models.EmailField(blank=True, verbose_name="Email")),
                ("hours", models.CharField(blank=True, max_length=200, verbose_name="Horaires")),
                ("description", models.TextField(blank=True, verbose_name="Description")),
                ("commissariat", models.CharField(blank=True, max_length=200, verbose_name="Commissariat")),
                ("zone_covered", models.CharField(blank=True, max_length=200, verbose_name="Zone couverte")),
                ("caserne", models.CharField(blank=True, max_length=200, verbose_name="Caserne")),
                ("intervention_zone", models.CharField(blank=True, max_length=200, verbose_name="Zone d'intervention")),
                ("emergency_number", models.CharField(blank=True, max_length=30, verbose_name="Numéro d'urgence")),
                ("hospital_type", models.CharField(blank=True, max_length=200, verbose_name="Type d'hôpital")),
                ("medical_services", models.TextField(blank=True, verbose_name="Services médicaux")),
                ("emergency_available", models.CharField(blank=True, max_length=200, verbose_name="Urgences disponibles")),
                ("mayor_name", models.CharField(blank=True, max_length=200, verbose_name="Nom du maire")),
                ("offered_services", models.TextField(blank=True, verbose_name="Services proposés")),
                ("service_type", models.CharField(blank=True, max_length=200, verbose_name="Type de service")),
                ("documents_delivered", models.TextField(blank=True, verbose_name="Documents délivrés")),
                ("school_name", models.CharField(blank=True, max_length=200, verbose_name="Nom de l'école")),
                ("education_level", models.CharField(blank=True, max_length=200, verbose_name="Niveau d'enseignement")),
                ("director", models.CharField(blank=True, max_length=200, verbose_name="Directeur")),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
            ],
            options={"db_table": "annuaires_entry", "ordering": ["-updated_at"], "verbose_name": "Directory Entry", "verbose_name_plural": "Directory Entries"},
        ),
    ]
