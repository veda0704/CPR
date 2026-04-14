from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path("admin/", admin.site.urls),
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
# Also explicitly serve the static folder where our audio is stored during dev
urlpatterns += static(settings.STATIC_URL, document_root=settings.BASE_DIR / 'static')
