from rest_framework import serializers
from django.contrib.auth.models import User
from datetime import date
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import Profile


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)

    class Meta:
        model = User
        fields = ['username', 'email', 'password']

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
        )
        return user


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Adds the username into the JWT payload so the client can read it
    without an extra API call."""

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['username'] = user.username
        return token


class ProfileSerializer(serializers.ModelSerializer):
    current_cycle_day = serializers.SerializerMethodField()
    current_phase = serializers.SerializerMethodField()

    class Meta:
        model = Profile
        fields = [
            'age', 'height_cm', 'weight_kg',
            'average_cycle_length', 'average_period_length',
            'last_period_start_date',
            'current_cycle_day', 'current_phase',
        ]

    def get_current_cycle_day(self, obj):
        if not obj.last_period_start_date:
            return None
        days_since = (date.today() - obj.last_period_start_date).days
        cycle_length = obj.average_cycle_length or 28
        return (days_since % cycle_length) + 1

    def get_current_phase(self, obj):
        day = self.get_current_cycle_day(obj)
        if day is None:
            return None
        period_len = obj.average_period_length or 5
        if day <= period_len:
            return "Menstrual"
        if day <= 13:
            return "Follicular"
        if day <= 16:
            return "Ovulation"
        return "Luteal"