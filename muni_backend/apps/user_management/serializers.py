from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()


# ─── Auth ─────────────────────────────────────────────────────────────────────

class RegisterSerializer(serializers.ModelSerializer):
    """Used by citizens to self-register."""

    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = (
            'username',
            'email',
            'phone_number',
            'password',
        )

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            phone_number=validated_data['phone_number'],
            password=validated_data['password'],
        )
        return user


# ─── Admin — Citizens ─────────────────────────────────────────────────────────

class CitizenSerializer(serializers.ModelSerializer):
    """
    Read-only for admin.
    Exposes the hashed password as stored in the DB.
    """

    class Meta:
        model = User
        fields = [
            'id',
            'username',
            'first_name',
            'last_name',
            'email',
            'phone_number',
            'password',       # hashed value
            'is_active',
            'date_joined',
        ]
        read_only_fields = fields


# ─── Admin — Agents ───────────────────────────────────────────────────────────

class AgentSerializer(serializers.ModelSerializer):
    """
    Full CRUD for agents.
    Password is write-only (never returned in responses).
    """

    password = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = User
        fields = [
            'id',
            'username',
            'first_name',
            'last_name',
            'email',
            'phone_number',
            'password',
            'agent_code',
            'department',
            'is_active',
            'date_joined',
        ]
        read_only_fields = ['id', 'date_joined']

    def create(self, validated_data):
        validated_data['role'] = 'agent'
        password = validated_data.pop('password', None)
        user = User(**validated_data)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save()
        return user

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        if password:
            instance.set_password(password)
        instance.save()
        return instance