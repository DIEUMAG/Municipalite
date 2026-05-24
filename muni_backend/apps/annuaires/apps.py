# apps/annuaires/apps.py
from django.apps import AppConfig

class AnnuairesConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.annuaires"   # must match what's in INSTALLED_APPS