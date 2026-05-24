from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend

from .models import Service, DirectoryEntry
from .serializers import ServiceSerializer, DirectoryEntrySerializer


class ServiceViewSet(viewsets.ReadOnlyModelViewSet):
    """
    List and retrieve directory services (Police, Pompiers, etc.).
    Services are pre-seeded via migrations; they are read-only from the API.
    """
    queryset = Service.objects.all()
    serializer_class = ServiceSerializer

    @action(detail=True, methods=["get"], url_path="entries")
    def entries(self, request, pk=None):
        """GET /api/services/{id}/entries/ — all entries for one service."""
        service = self.get_object()
        entries = service.entries.all()
        serializer = DirectoryEntrySerializer(entries, many=True)
        return Response(serializer.data)


class DirectoryEntryViewSet(viewsets.ModelViewSet):
    """
    Full CRUD for directory entries.

    Filters:
      ?service=<id>         — entries for a specific service
      ?search=<q>           — search name, responsible, address
    """
    queryset = DirectoryEntry.objects.select_related("service").all()
    serializer_class = DirectoryEntrySerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["service"]
    search_fields = ["name", "responsible", "address", "email", "phone"]
    ordering_fields = ["name", "updated_at", "created_at"]
    ordering = ["-updated_at"]

    def create(self, request, *args, **kwargs):
        """POST /api/entries/ — create a new directory entry."""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def update(self, request, *args, **kwargs):
        """PUT/PATCH /api/entries/{id}/ — update an entry."""
        kwargs["partial"] = True  # always allow partial update (like Flutter's save)
        return super().update(request, *args, **kwargs)
