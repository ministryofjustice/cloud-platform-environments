from django.test import TestCase
from .models import Person


class URLTests(TestCase):

    def test_homepage(self):
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)


class PersonTest(TestCase):

    def test_person_creation(self):
        person = Person.objects.create(name='test_user', job='test_job')
        self.assertEqual(person.__str__(), person.name)
