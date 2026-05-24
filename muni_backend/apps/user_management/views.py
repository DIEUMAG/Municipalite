from django.shortcuts import render

# Create your views here.
from rest_framework import generics, viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.contrib.auth import get_user_model

from .serializers import RegisterSerializer, CitizenSerializer, AgentSerializer

User = get_user_model()


# ─── Auth ─────────────────────────────────────────────────────────────────────

class RegisterView(generics.CreateAPIView):
    """POST /api/auth/register/ — citizen self-registration (unchanged)."""

    queryset = User.objects.all()
    serializer_class = RegisterSerializer


# ─── Admin — Citizens ─────────────────────────────────────────────────────────

class CitizenViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Admin read-only access to citizens.
    GET /api/citizens/              — list all citizens
    GET /api/citizens/{id}/         — detail of one citizen
    GET /api/citizens/?search=<q>   — search by name, email, username, phone
    """

    queryset = User.objects.filter(role='citizen').order_by('-date_joined')
    serializer_class = CitizenSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['username', 'first_name', 'last_name', 'email', 'phone_number']
    ordering_fields = ['date_joined', 'username', 'last_name']

    @action(detail=True, methods=['patch'], url_path='toggle-active')
    def toggle_active(self, request, pk=None):
        """PATCH /api/citizens/{id}/toggle-active/ — activate or deactivate."""
        user = self.get_object()
        user.is_active = not user.is_active
        user.save()
        return Response({'id': user.id, 'is_active': user.is_active})


# ─── Admin — Agents ───────────────────────────────────────────────────────────

class AgentViewSet(viewsets.ModelViewSet):
    """
    Full CRUD for agents.
    GET    /api/agents/             — list all agents
    POST   /api/agents/             — create a new agent
    GET    /api/agents/{id}/        — detail
    PATCH  /api/agents/{id}/        — update
    DELETE /api/agents/{id}/        — delete
    """

    queryset = User.objects.filter(role='agent').order_by('-date_joined')
    serializer_class = AgentSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['is_active', 'department']
    search_fields = ['username', 'first_name', 'last_name', 'email', 'agent_code', 'department']
    ordering_fields = ['date_joined', 'username', 'last_name']

    @action(detail=True, methods=['patch'], url_path='toggle-active')
    def toggle_active(self, request, pk=None):
        """PATCH /api/agents/{id}/toggle-active/ — activate or deactivate."""
        user = self.get_object()
        user.is_active = not user.is_active
        user.save()
        return Response({'id': user.id, 'is_active': user.is_active})