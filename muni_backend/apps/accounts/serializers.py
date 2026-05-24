from rest_framework import serializers
from .models import User


class RegisterSerializer(serializers.ModelSerializer):

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

            password=validated_data['password']
        )

        return user