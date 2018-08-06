from django.db import models


class Person(models.Model):
    name = models.CharField(max_length=30)
    job = models.CharField(max_length=30)
    date_created = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name
