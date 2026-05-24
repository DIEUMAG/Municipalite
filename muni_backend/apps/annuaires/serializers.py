from rest_framework import serializers
from .models import Service, DirectoryEntry


class ServiceSerializer(serializers.ModelSerializer):
    entry_count = serializers.IntegerField(source="entries.count", read_only=True)

    class Meta:
        model = Service
        fields = ["id", "title", "icon", "color", "entry_count"]


class DirectoryEntrySerializer(serializers.ModelSerializer):
    service_title = serializers.CharField(source="service.title", read_only=True)

    class Meta:
        model = DirectoryEntry
        fields = [
            "id",
            "service",
            "service_title",
            # General
            "name",
            "responsible",
            "phone",
            "address",
            "email",
            "hours",
            "description",
            # Police
            "commissariat",
            "zone_covered",
            # Pompiers
            "caserne",
            "intervention_zone",
            # Shared Police + Pompiers
            "emergency_number",
            # Hôpitaux
            "hospital_type",
            "medical_services",
            "emergency_available",
            # Mairie
            "mayor_name",
            "offered_services",
            # Services administratifs
            "service_type",
            "documents_delivered",
            # Éducation
            "school_name",
            "education_level",
            "director",
            # Timestamps
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at", "service_title"]
