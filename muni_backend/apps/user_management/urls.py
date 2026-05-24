from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .views import RegisterView, CitizenViewSet, AgentViewSet

router = DefaultRouter()
router.register(r'citizens', CitizenViewSet, basename='citizen')
router.register(r'agents', AgentViewSet, basename='agent')

urlpatterns = [

    # ── Auth (unchanged) ──────────────────────────────────────────────────────
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', TokenObtainPairView.as_view(), name='login'),
    path('refresh/', TokenRefreshView.as_view(), name='refresh'),

    # ── Admin user management ─────────────────────────────────────────────────
    path('', include(router.urls)),
]