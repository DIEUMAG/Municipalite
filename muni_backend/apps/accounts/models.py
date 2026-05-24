from django.db import models

# Create your models here.
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):

    phone_number = models.CharField(
        max_length=20,
        blank=True,
        null=True
    )

    ROLE_CHOICES = (

        ('citizen', 'Citizen'),
        ('admin', 'Admin'),
        ('agent', 'Agent'),
    )

    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default='citizen'
    )

    def __str__(self):
        return self.username