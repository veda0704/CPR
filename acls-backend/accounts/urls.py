from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .api_views import api_login, api_signup, api_me

urlpatterns = [
    # API Endpoints for React Frontend
    path("login/", api_login, name="api_login"),
    path("signup/", api_signup, name="api_signup"),
    path("me/", api_me, name="api_me"),
    path("refresh/", TokenRefreshView.as_view(), name="token_refresh"),
]

