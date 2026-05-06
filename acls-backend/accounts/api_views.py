from django.contrib.auth import authenticate, get_user_model
from django.conf import settings
from django.views.decorators.csrf import ensure_csrf_cookie
from rest_framework.decorators import api_view, permission_classes, throttle_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import UserSerializer, LoginSerializer, SignupSerializer

User = get_user_model()

def get_tokens(user):
    refresh = RefreshToken.for_user(user)
    return {
        "access": str(refresh.access_token),
        "refresh": str(refresh),
    }


def format_validation_error(errors, code='invalid_input', detail='Validation failed'):
    return Response({
        'code': code,
        'detail': detail,
        'errors': errors,
    }, status=400)


def build_refresh_cookie(response, refresh_token, remember):
    max_age = 60 * 60 * 24 * 30 if remember else None
    response.set_cookie(
        'refresh_token',
        refresh_token,
        httponly=True,
        secure=not settings.DEBUG,
        samesite='Lax',
        max_age=max_age,
        path='/api/accounts/',
    )
    return response

@api_view(["POST"])
@permission_classes([AllowAny])
@throttle_classes([ScopedRateThrottle])
def api_login(request):
    serializer = LoginSerializer(data=request.data)
    if not serializer.is_valid():
        return format_validation_error(serializer.errors)
    
    email = serializer.validated_data.get("email")
    password = serializer.validated_data.get("password")
    remember_me = serializer.validated_data.get('remember_me', False)

    user = authenticate(username=email, password=password)
    if not user:
        return Response({"code": "invalid_credentials", "detail": "Invalid credentials"}, status=401)

    tokens = get_tokens(user)
    response = Response({
        "success": True,
        "access": tokens["access"],
        "refresh": tokens["refresh"],
        "user": UserSerializer(user).data
    })
    return build_refresh_cookie(response, tokens["refresh"], remember_me)
api_login.throttle_scope = 'login'

@api_view(["POST"])
@permission_classes([AllowAny])
@throttle_classes([ScopedRateThrottle])
def api_signup(request):
    serializer = SignupSerializer(data=request.data)
    if not serializer.is_valid():
        return format_validation_error(serializer.errors)
    
    user = serializer.save()
    # TODO: Send actual email confirmation before allowing full access.
    
    tokens = get_tokens(user)
    response = Response({
        "success": True,
        "message": "Account created successfully. You can now log in.",
        "access": tokens["access"],
        "refresh": tokens["refresh"],
        "user": UserSerializer(user).data
    })
    return build_refresh_cookie(response, tokens["refresh"], remember=False)
api_signup.throttle_scope = 'signup'

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def api_me(request):
    return Response(UserSerializer(request.user).data)

@api_view(["POST"])
@permission_classes([AllowAny])
@throttle_classes([ScopedRateThrottle])
def api_logout(request):
    response = Response({"success": True})
    response.delete_cookie('refresh_token', path='/api/accounts/')
    return response
api_logout.throttle_scope = 'refresh'

@api_view(["POST"])
@permission_classes([AllowAny])
@throttle_classes([ScopedRateThrottle])
def api_refresh(request):
    refresh_token = (
        request.COOKIES.get('refresh_token') or
        request.data.get('refresh')
    )
    if not refresh_token:
        return Response({"error": "Refresh token missing"}, status=401)

    try:
        refresh = RefreshToken(refresh_token)
        return Response({"access": str(refresh.access_token)})
    except TokenError as e:
        return Response({"code": "invalid_refresh_token", "detail": str(e)}, status=401)
api_refresh.throttle_scope = 'refresh'
