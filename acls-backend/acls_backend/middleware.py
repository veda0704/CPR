from django.http import HttpResponse
from django.utils.deprecation import MiddlewareMixin

class NoCacheMiddleware(MiddlewareMixin):
    """
    Middleware to prevent browser caching of all pages.
    This ensures that after logout, the back button doesn't show cached pages.
    """
    def process_response(self, request, response):
        # Set cache control headers to prevent caching for all responses
        response['Cache-Control'] = 'no-cache, no-store, must-revalidate'
        response['Pragma'] = 'no-cache'
        response['Expires'] = '0'
        return response
