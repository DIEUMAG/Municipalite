
# Create your models here.
from django.db import models
from django.conf import settings


class Incident(models.Model):

    STATUS_CHOICES = (

        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('resolved', 'Resolved'),
    )

    user = models.ForeignKey(

        settings.AUTH_USER_MODEL,

        on_delete=models.CASCADE
    )

    title = models.CharField(max_length=255)

    description = models.TextField()

    image = models.ImageField(
        upload_to='incidents/',
        blank=True,
        null=True
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    def __str__(self):
        return self.title