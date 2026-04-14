from django.contrib.auth import authenticate, get_user_model
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import UserSerializer, LoginSerializer, SignupSerializer

User = get_user_model()

def get_tokens(user):
    refresh = RefreshToken.for_user(user)
    return {
        "access": str(refresh.access_token),
        "refresh": str(refresh),
    }

@api_view(["POST"])
@permission_classes([AllowAny])
def api_login(request):
    serializer = LoginSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=400)
    
    email = serializer.validated_data.get("email")
    password = serializer.validated_data.get("password")

    user = authenticate(username=email, password=password)
    if not user:
        return Response({"error": "Invalid credentials"}, status=401)

    tokens = get_tokens(user)
    return Response({
        "success": True,
        "tokens": tokens,
        "user": UserSerializer(user).data
    })

@api_view(["POST"])
@permission_classes([AllowAny])
def api_signup(request):
    serializer = SignupSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=400)
    
    user = serializer.save()
    tokens = get_tokens(user)

    return Response({
        "success": True,
        "tokens": tokens,
        "user": UserSerializer(user).data
    })

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def api_me(request):
    return Response(UserSerializer(request.user).data)
