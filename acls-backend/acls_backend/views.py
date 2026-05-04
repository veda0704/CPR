from django.http import JsonResponse
from django.views.decorators.http import require_http_methods

@require_http_methods(["GET"])
def ratelimit_view(request, exception):
    """Custom view for rate limit exceeded."""
    return JsonResponse({
        'error': 'Too many requests. Please try again later.',
        'retry_after': getattr(exception, 'retry_after', 60)
    }, status=429)