from django.db import migrations


SERVICES = [
    {"title": "Police",                  "icon": "local_police",    "color": "blue"},
    {"title": "Pompiers",                "icon": "fire_truck",      "color": "red"},
    {"title": "Hôpitaux",               "icon": "local_hospital",  "color": "green"},
    {"title": "Mairie",                  "icon": "account_balance", "color": "orange"},
    {"title": "Services administratifs","icon": "business_center", "color": "purple"},
    {"title": "Éducation",              "icon": "school",          "color": "teal"},
]


def seed_services(apps, schema_editor):
    Service = apps.get_model("annuaires", "Service")
    for svc in SERVICES:
        Service.objects.get_or_create(title=svc["title"], defaults=svc)


def unseed_services(apps, schema_editor):
    Service = apps.get_model("annuaires", "Service")
    Service.objects.filter(title__in=[s["title"] for s in SERVICES]).delete()


class Migration(migrations.Migration):

    dependencies = [
        ("annuaires", "0001_initial"),
    ]

    operations = [
        migrations.RunPython(seed_services, reverse_code=unseed_services),
    ]
