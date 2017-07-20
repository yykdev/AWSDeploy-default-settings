import json

from django.contrib.auth.models import User
from django.core.management import BaseCommand

from config import settings


class Command(BaseCommand):
    def handle(self, *args, **options):
        config_secret_common = json.loads(open(settings.CONFIG_SECRET_COMMON_FILE)).read()
        username = config_secret_common['django']['default_superuser']['username']
        password = config_secret_common['django']['default_superuser']['password']
        if not User.objects.filter(username=username).exists():
            User.objects.create_superuser(
                username=username,
                password=password,
                email=''
            )