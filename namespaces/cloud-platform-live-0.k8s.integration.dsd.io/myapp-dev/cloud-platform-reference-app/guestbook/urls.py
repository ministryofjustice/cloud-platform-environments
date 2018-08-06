from django.urls import path
from guestbook.views import guestlist, s3test


app_name = 'guestbook'
urlpatterns = [
    path('s3test/', s3test, name='s3test'),
    path('', guestlist, name='guestlist'),
]
