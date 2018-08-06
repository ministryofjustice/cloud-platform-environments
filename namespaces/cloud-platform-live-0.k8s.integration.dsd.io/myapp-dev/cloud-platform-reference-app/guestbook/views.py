import os
import platform
from django.shortcuts import render, redirect
from .modelforms import PersonForm
from .models import Person
import boto3
import botocore


def guestlist(request):
    form = PersonForm(request.POST or None)
    if form.is_valid():
        form.save()
        return redirect('guestbook:guestlist')

    context = {
        'people': Person.objects.order_by('-date_created'),
    }

    return render(request, 'guestlist.html', context)


def s3test(request):
    BUCKET_NAME = 'cloud-platform-reference-bucket'
    FILE_NAME = 'hello.txt'
    with open(FILE_NAME, 'rb') as f:
        fstr = f.read()
    if request.method == 'POST':
        pass
    else:
        if (os.getppid() == 1):
            osname = 'Docker'
        else:
            osname = platform.system()
    status = ""
    try:
        session = boto3.Session()
        s3_client = session.client('s3')
        s3_client.put_object(Body=fstr, Bucket=BUCKET_NAME, Key='upload-' + FILE_NAME)
        status = "Write OK"
    except botocore.exceptions.ClientError as e:
        status = "Write Failed: ", e
    return render(request, 'test-s3.html', {'osname': osname, 'status': status})
