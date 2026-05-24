from rest_framework import viewsets, filters, parsers, status
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Acte, ActeNaissance
from .serializers import ActeSerializer, ActeNaissanceSerializer


class ActeViewSet(viewsets.ModelViewSet):
    queryset         = Acte.objects.all()
    serializer_class = ActeSerializer
    parser_classes   = [parsers.MultiPartParser, parsers.FormParser, parsers.JSONParser]
    filter_backends  = [filters.SearchFilter, filters.OrderingFilter]
    search_fields    = ['nom_complet', 'type_acte']
    ordering_fields  = ['date_upload', 'type_acte']
    ordering         = ['-date_upload']


class ActeNaissanceViewSet(viewsets.ModelViewSet):
    queryset         = ActeNaissance.objects.all()
    serializer_class = ActeNaissanceSerializer
    filter_backends  = [filters.SearchFilter, filters.OrderingFilter]
    search_fields    = ['enfant_noms', 'enfant_prenoms', 'numero_acte', 'statut']
    ordering_fields  = ['created_at', 'date_etablissement', 'statut']
    ordering         = ['-created_at']

    @action(detail=True, methods=['patch'], url_path='statut')
    def update_statut(self, request, pk=None):
        """PATCH /actes-naissance/{id}/statut/ — update statut only"""
        instance = self.get_object()
        new_statut = request.data.get('statut')
        valid = [s[0] for s in ActeNaissance.STATUT_CHOICES]
        if new_statut not in valid:
            return Response(
                {'error': f"Statut invalide. Choisir parmi: {valid}"},
                status=status.HTTP_400_BAD_REQUEST
            )
        instance.statut = new_statut
        instance.save()
        return Response(ActeNaissanceSerializer(instance).data)