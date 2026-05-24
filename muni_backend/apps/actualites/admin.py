from django.contrib import admin

# Register your models here.
from django.contrib import admin

from .models import Actualite, Media


admin.site.register(Actualite)
admin.site.register(Media)