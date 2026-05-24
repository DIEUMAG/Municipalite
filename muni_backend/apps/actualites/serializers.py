from rest_framework import serializers

from .models import Actualite, Media


class MediaSerializer(serializers.ModelSerializer):

    fichier = serializers.SerializerMethodField()

    class Meta:
        model = Media
        fields = ['id', 'fichier', 'is_video']

    def get_fichier(self, obj):
        request = self.context.get('request')

        if request:
            return request.build_absolute_uri(obj.fichier.url)

        return obj.fichier.url


class ActualiteSerializer(serializers.ModelSerializer):

    medias = MediaSerializer(many=True, read_only=True)

    class Meta:
        model = Actualite
        fields = [
            'id',
            'titre',
            'corps',
            'created_at',
            'medias',
        ]