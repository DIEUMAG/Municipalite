from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ServiceViewSet, DirectoryEntryViewSet

router = DefaultRouter()
router.register(r"services", ServiceViewSet, basename="service")
router.register(r"entries", DirectoryEntryViewSet, basename="entry")

urlpatterns = [
    path("", include(router.urls)),
]
