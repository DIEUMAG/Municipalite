from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets
from rest_framework.permissions import AllowAny
from rest_framework.parsers import MultiPartParser, FormParser

from .models import Actualite, Media
from .serializers import ActualiteSerializer


class ActualiteViewSet(viewsets.ModelViewSet):

    queryset = Actualite.objects.all().order_by('-created_at')

    serializer_class = ActualiteSerializer

    permission_classes = [AllowAny]

    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):

        actualite = serializer.save()

        files = self.request.FILES.getlist('medias')

        for file in files:

            Media.objects.create(
                actualite=actualite,
                fichier=file,
                is_video=file.content_type.startswith('video'),
            )