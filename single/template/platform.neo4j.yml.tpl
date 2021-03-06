apiVersion: "apps/v1beta1"
kind: StatefulSet
metadata:
  name: neo4j-core
  namespace: ${NS_DEFAULT}
spec:
  serviceName: neo4j
  replicas: 1
  template:
    metadata:
      labels:
        app: neo4j
        component: core
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
                - key: app
                  operator: In
                  values:
                  - neo4j
            topologyKey: kubernetes.io/hostname
      containers:
      - name: neo4j
        #image: "neo4j:3.5-enterprise"
        image: "neo4j:3.5.5-enterprise"
        imagePullPolicy: "IfNotPresent"
        env:
          - name: NEO4J_AUTH
            value: neo4j/pentium
          - name: NEO4J_ACCEPT_LICENSE_AGREEMENT
            value: "yes"
        ports:
        - containerPort: 7474
          name: browser
        - containerPort: 7687
          name: bolt
        securityContext:
          privileged: true
        volumeMounts:
        - name: datadir
          mountPath: "/data"
        - name: logdir
          mountPath: "/logs"
        - name: import
          mountPath: "/var/lib/neo4j/import"
        - name: plugin
          mountPath: "/plugins"
        #- name: config
        #  mountPath: "/var/lib/neo4j/conf/neo4j.conf"
        #  subPath: neo4j.conf
        #  readOnly: false
      volumes:
       - name: datadir
         hostPath:
           path: /opt/neo4j/${NS_DEFAULT}
       - name: logdir
         hostPath:
           path: /opt/neo4j/logs/${NS_DEFAULT}
       - name: import
         hostPath:
           path: /opt/neo4j/import/${NS_DEFAULT}
       - name: plugin
         hostPath:
           path: /opt/neo4j/plugin/${NS_DEFAULT}
       #- name: config
       #  configMap:
       #     name: neo4j-config
            #items:
            #- key: neo4j.conf
            #  path: neo4j.conf
            #optional: true
      nodeSelector:
        ptnodetype: "datanode"
#  volumeClaimTemplates:
#    - metadata:
#        name: datadir
#      spec:
#        accessModes:
#          - ReadWriteOnce
#        storageClassName: "standard"
#        resources:
#          requests:
#            storage: "10Gi"
---
apiVersion: v1
kind: Service
metadata:
  name: neo4j
  namespace: ${NS_DEFAULT}
  labels:
    app: neo4j
    component: core
spec:
  clusterIP: None
  ports:
    - port: 7474
      targetPort: 7474
      name: browser
    - port: 6362
      targetPort: 6362
      name: backup
    - port: 7687
      targetPort: 7687
      name: bolt
  selector:
    app: neo4j
    component: core
---
apiVersion: v1
kind: Service
metadata:
  name: neo4j-n
  namespace: ${NS_DEFAULT}
  labels:
    app: neo4j
    component: core
spec:
  ports:
  - name: neo4jconnect
    protocol: TCP
    port: 7474
    targetPort: 7474
  - name: neo4balt
    protocol: TCP
    port: 7687
    targetPort: 7687
  type: NodePort
  selector:
    app: neo4j
    component: core
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: neo4j-config
  namespace: ${NS_DEFAULT}
data:
  neo4j.conf: |
    ---
    dbms.connectors.default_listen_address=0.0.0.0
    dbms.connector.bolt.enabled=true
    dbms.connector.bolt.thread_pool_min_size=10
    dbms.connector.bolt.thread_pool_max_size=10000
    dbms.connector.bolt.thread_pool_keep_alive=10m
    dbms.connector.http.enabled=true
    dbms.connector.https.enabled=true
    dbms.jvm.additional=-XX:+UseG1GC
    dbms.jvm.additional=-XX:-OmitStackTraceInFastThrow
    dbms.jvm.additional=-XX:+AlwaysPreTouch
    dbms.jvm.additional=-XX:+UnlockExperimentalVMOptions
    dbms.jvm.additional=-XX:+TrustFinalNonStaticFields
    dbms.jvm.additional=-XX:+DisableExplicitGC
    dbms.jvm.additional=-Djdk.tls.ephemeralDHKeySize=2048
    dbms.jvm.additional=-Djdk.tls.rejectClientInitiatedRenegotiation=true
    dbms.windows_service_name=neo4j
    dbms.jvm.additional=-Dunsupported.dbms.udc.source=rpm
