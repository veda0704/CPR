from django.http import HttpResponse
from django.utils.deprecation import MiddlewareMixin

class NoCacheMiddleware(MiddlewareMixin):
    """
    Middleware to prevent browser caching of all pages.
    This ensures that after logout, the back button doesn't show cached pages.
    """
    def process_response(self, request, response):
        response['Cache-Control'] = 'no-cache, no-store, must-revalidate'
        response['Pragma'] = 'no-cache'
        response['Expires'] = '0'
        return response

class SecurityHeadersMiddleware(MiddlewareMixin):
    """Adds security headers to reduce injection and clickjacking risk."""
    def process_response(self, request, response):
        response['X-Content-Type-Options'] = 'nosniff'
        response['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        response['Permissions-Policy'] = 'interest-cohort=()'
        response['Content-Security-Policy'] = "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self' https:; frame-ancestors 'none';"
        return response
