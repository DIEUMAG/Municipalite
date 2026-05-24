from rest_framework import serializers
from .models import Acte, ActeNaissance


class ActeSerializer(serializers.ModelSerializer):
    type_acte_display = serializers.CharField(source='get_type_acte_display', read_only=True)
    fichier_url = serializers.SerializerMethodField()

    class Meta:
        model = Acte
        fields = ['id', 'type_acte', 'type_acte_display', 'fichier', 'fichier_url',
                  'nom_complet', 'description', 'date_upload', 'updated_at']
        read_only_fields = ['id', 'date_upload', 'updated_at', 'fichier_url']

    def get_fichier_url(self, obj):
        request = self.context.get('request')
        if obj.fichier and request:
            return request.build_absolute_uri(obj.fichier.url)
        return None


class ActeNaissanceSerializer(serializers.ModelSerializer):
    statut_display         = serializers.CharField(source='get_statut_display', read_only=True)
    mere_situation_display = serializers.CharField(source='get_mere_situation_matrimoniale_display', read_only=True)
    mere_niveau_display    = serializers.CharField(source='get_mere_niveau_scolaire_display', read_only=True)
    pere_niveau_display    = serializers.CharField(source='get_pere_niveau_scolaire_display', read_only=True)

    class Meta:
        model = ActeNaissance
        fields = [
            'id', 'id_unique', 'numero_acte', 'date_etablissement', 'statut', 'statut_display',
            'enfant_noms', 'enfant_prenoms', 'enfant_date_naissance', 'enfant_lieu_naissance',
            'mere_noms', 'mere_date_naissance', 'mere_lieu_residence', 'mere_duree_residence',
            'mere_profession', 'mere_contact', 'mere_situation_matrimoniale', 'mere_situation_display',
            'mere_niveau_scolaire', 'mere_niveau_display',
            'mere_nationalite', 'mere_cni', 'mere_nb_enfants',
            'pere_noms', 'pere_date_lieu_naissance', 'pere_domicile', 'pere_profession',
            'pere_contact', 'pere_niveau_scolaire', 'pere_niveau_display',
            'pere_nationalite', 'pere_cni',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'id_unique', 'numero_acte', 'date_etablissement',
                            'statut', 'created_at', 'updated_at']