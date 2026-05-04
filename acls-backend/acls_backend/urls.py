from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

def health_check(request):
    return JsonResponse({'status': 'ok'})

urlpatterns = [
    path("admin/", admin.site.urls),
    # Health check endpoint
    path('api/health/', health_check, name='health_check'),
    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/schema/swagger-ui/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/schema/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
    # Account & Auth APIs
    path("api/accounts/", include("accounts.urls")),
    # ACLS Simulation APIs
    path("api/acls/", include("acls.urls")),
    # Language Support
    path("i18n/", include("django.conf.urls.i18n")),
]

# Serve static files in development
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
# Also explicitly serve the static folder where our audio is stored during dev
urlpatterns += static(settings.STATIC_URL, document_root=settings.BASE_DIR / 'static')
