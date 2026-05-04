from django.urls import path
from .api_views import api_login, api_signup, api_me, api_refresh, api_logout

urlpatterns = [
    # API Endpoints for React Frontend
    path("login/", api_login, name="api_login"),
    path("signup/", api_signup, name="api_signup"),
    path("me/", api_me, name="api_me"),
    path("refresh/", api_refresh, name="api_refresh"),
    path("logout/", api_logout, name="api_logout"),
]

