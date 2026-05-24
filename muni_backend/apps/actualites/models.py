from django.db import models

# Create your models here.
from django.db import models


class Actualite(models.Model):

    titre = models.CharField(max_length=255)

    corps = models.TextField()

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.titre


class Media(models.Model):

    actualite = models.ForeignKey(
        Actualite,
        related_name='medias',
        on_delete=models.CASCADE,
    )

    fichier = models.FileField(
        upload_to='actualites/',
    )

    is_video = models.BooleanField(default=False)