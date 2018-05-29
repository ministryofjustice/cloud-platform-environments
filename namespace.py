 #!/usr/bin/python3

import subprocess, json
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("-c", "--cluster", dest="cluster",
                    help="Cluster to run this on", required=True)

args = parser.parse_args()
cluster = vars(args)['cluster']

default_namespaces = ['default', 'kube-public', 'kube-system']
k8_namespaces = []
dir_namespaces = str(subprocess.check_output(['ls', 'namespaces/' + cluster + '/']).decode('utf-8')).split()
k8_json = json.loads(str(subprocess.check_output(["kubectl", "get", "namespaces", "-o", "json"]).decode('utf-8')))

print('cluster', cluster)

for item in dir_namespaces:
  try:
    print('kubectl create namespace', item)
    print(subprocess.check_output(['kubectl', 'create', '-f', 'namespaces/' + cluster + '/'  + item + '/namespace.yaml']) )
  except subprocess.CalledProcessError as e:
    print('exit code 1') 

  print('kubectl apply namespace', item)
  print(subprocess.check_output(['kubectl', 'apply', '-f', 'namespaces/' + cluster + '/' + item, '--namespace=' + item]) )

  print('helm init', item)
  print(subprocess.check_output(['helm', 'init', '--service-account', 'tiller', '--tiller-namespace', item]) )

for item in k8_json['items']:
  k8_namespaces.append(item['metadata']['name'])

for item in dir_namespaces:
  if item in k8_namespaces:
    k8_namespaces.remove(item)

for item in default_namespaces:
  if item in k8_namespaces:
    k8_namespaces.remove(item)

for item in k8_namespaces:
  if item:
    print('kubectl delete namespaces', item)
    print(subprocess.check_output(['kubectl', 'delete', 'namespaces', item]) )
