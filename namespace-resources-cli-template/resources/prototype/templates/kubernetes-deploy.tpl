apiVersion: apps/v1
kind: Deployment
metadata:
  name: moj-prototype-${BRANCH}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prototype-${BRANCH}
  template:
    metadata:
      labels:
        app: prototype-${BRANCH}
    spec:
      containers:
      - name: nginx
        image: 754256621582.dkr.ecr.eu-west-2.amazonaws.com/${ECR_NAME}:${IMAGE_TAG}
        env:
          - name: USERNAME
            valueFrom:
              secretKeyRef:
                name: basic-auth
                key: username
          - name: PASSWORD
            valueFrom:
              secretKeyRef:
                name: basic-auth
                key: password
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-${BRANCH}
  labels:
    app: nginx-service-${BRANCH}
spec:
  ports:
  - port: 3000
    name: http
    targetPort: 3000
  selector:
    app: prototype-${BRANCH}
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: prototype-ingress-${BRANCH}
  annotations:
    kubernetes.io/ingress.class: nginx
    external-dns.alpha.kubernetes.io/set-identifier: prototype-ingress-${BRANCH}-${KUBE_NAMESPACE}-green
    external-dns.alpha.kubernetes.io/aws-weight: "100"
spec:
  tls:
  - hosts:
    - ${KUBE_NAMESPACE}-${BRANCH}.apps.live.cloud-platform.service.justice.gov.uk
  rules:
  - host: ${KUBE_NAMESPACE}-${BRANCH}.apps.live.cloud-platform.service.justice.gov.uk
    http:
      paths:
      - path: /
        backend:
          serviceName: nginx-service-${BRANCH}
          servicePort: 3000