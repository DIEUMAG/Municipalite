from django.urls import path, include

from rest_framework.routers import DefaultRouter

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

from .views import ActualiteViewSet


router = DefaultRouter()

router.register(
    r'actualites',
    ActualiteViewSet,
)


urlpatterns = [

    # JWT LOGIN
    path(
        'token/',
        TokenObtainPairView.as_view(),
        name='token_obtain_pair',
    ),

    # JWT REFRESH
    path(
        'token/refresh/',
        TokenRefreshView.as_view(),
        name='token_refresh',
    ),

    # ACTUALITES
    path(
        '',
        include(router.urls),
    ),
]