from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, filters, parsers, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend

from .models import Acte, ActeNaissance
from .serializers import ActeSerializer, ActeNaissanceSerializer


class ActeViewSet(viewsets.ModelViewSet):
    queryset = Acte.objects.all()
    serializer_class = ActeSerializer
    parser_classes = [parsers.MultiPartParser, parsers.FormParser, parsers.JSONParser]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['type_acte']
    search_fields = ['nom_complet', 'description']
    ordering_fields = ['date_upload', 'type_acte']


class ActeNaissanceViewSet(viewsets.ModelViewSet):
    """
    POST   /api/actes-naissance/          — soumettre une demande
    GET    /api/actes-naissance/          — lister toutes les demandes
    GET    /api/actes-naissance/{id}/     — voir le détail d'une demande
    PATCH  /api/actes-naissance/{id}/     — modifier
    DELETE /api/actes-naissance/{id}/     — supprimer
    GET    /api/actes-naissance/?search=  — rechercher
    """
    queryset = ActeNaissance.objects.all()
    serializer_class = ActeNaissanceSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['statut']
    search_fields = ['enfant_noms', 'enfant_prenoms', 'mere_noms', 'pere_noms',
                     'numero_acte', 'id_unique']
    ordering_fields = ['created_at', 'enfant_noms', 'statut']

    @action(detail=True, methods=['patch'], url_path='valider')
    def valider(self, request, pk=None):
        """PATCH /api/actes-naissance/{id}/valider/ — admin validates the request."""
        acte = self.get_object()
        acte.statut = 'validee'
        acte.save()
        return Response(ActeNaissanceSerializer(acte).data)

    @action(detail=True, methods=['patch'], url_path='rejeter')
    def rejeter(self, request, pk=None):
        """PATCH /api/actes-naissance/{id}/rejeter/ — admin rejects the request."""
        acte = self.get_object()
        acte.statut = 'rejetee'
        acte.save()
        return Response(ActeNaissanceSerializer(acte).data)