from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ActeViewSet, ActeNaissanceViewSet

router = DefaultRouter()
router.register(r'actes',          ActeViewSet,          basename='acte')
router.register(r'actes-naissance', ActeNaissanceViewSet, basename='acte-naissance')

urlpatterns = [
    path('', include(router.urls)),
]