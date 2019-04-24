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
        image: "neo4j:3.5-enterprise"
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
    #*****************************************************************
    # Neo4j configuration
    #
    # For more details and a complete list of settings, please see
    # https://neo4j.com/docs/operations-manual/current/reference/configuration-settings/
    #*****************************************************************

    # The name of the database to mount
    #dbms.active_database=graph.db

    # Paths of directories in the installation.
    #dbms.directories.data=data
    #dbms.directories.certificates=certificates
    #dbms.directories.lib=lib
    #dbms.directories.run=run

    # This setting constrains all `LOAD CSV` import files to be under the `import` directory. Remove or comment it out to
    # allow files to be loaded from anywhere in the filesystem; this introduces possible security problems. See the
    # `LOAD CSV` section of the manual for details.
    dbms.directories.import=import

    # Whether requests to Neo4j are authenticated.
    # To disable authentication, uncomment this line
    #dbms.security.auth_enabled=false

    # Enable this to be able to upgrade a store from an older version.
    #dbms.allow_upgrade=true

    # Java Heap Size: by default the Java heap size is dynamically
    # calculated based on available system resources.
    # Uncomment these lines to set specific initial and maximum
    # heap size.

    # The amount of memory to use for mapping the store files, in bytes (or
    # kilobytes with the 'k' suffix, megabytes with 'm' and gigabytes with 'g').
    # If Neo4j is running on a dedicated server, then it is generally recommended
    # to leave about 2-4 gigabytes for the operating system, give the JVM enough
    # heap to hold all your transaction state and query context, and then leave the
    # rest for the page cache.
    # The default page cache memory assumes the machine is dedicated to running
    # Neo4j, and is heuristically set to 50% of RAM minus the max Java heap size.

    #*****************************************************************
    # Network connector configuration
    #*****************************************************************

    # With default configuration Neo4j only accepts local connections.
    # To accept non-local connections, uncomment this line:

    # You can also choose a specific network interface, and configure a non-default
    # port for each connector, by setting their individual listen_address.

    # The address at which this server can be reached by its clients. This may be the server's IP address or DNS name, or
    # it may be the address of a reverse proxy which sits in front of the server. This setting may be overridden for
    # individual connectors below.
    #dbms.connectors.default_advertised_address=localhost

    # You can also choose a specific advertised hostname or IP address, and
    # configure an advertised port for each connector, by setting their
    # individual advertised_address.

    # Bolt connector
    dbms.connector.bolt.enabled=true
    #dbms.connector.bolt.tls_level=OPTIONAL

    # HTTP Connector. There can be zero or one HTTP connectors.
    dbms.connector.http.enabled=true

    # HTTPS Connector. There can be zero or one HTTPS connectors.
    dbms.connector.https.enabled=true

    # Number of Neo4j worker threads.
    #dbms.threads.worker_count=

    #*****************************************************************
    # SSL system configuration
    #*****************************************************************

    # Names of the SSL policies to be used for the respective components.

    # The legacy policy is a special policy which is not defined in
    # the policy configuration section, but rather derives from
    # dbms.directories.certificates and associated files
    # (by default: neo4j.key and neo4j.cert). Its use will be deprecated.

    # The policies to be used for connectors.
    #
    # N.B: Note that a connector must be configured to support/require
    #      SSL/TLS for the policy to actually be utilized.
    #
    # see: dbms.connector.*.tls_level

    #bolt.ssl_policy=legacy
    #https.ssl_policy=legacy

    #*****************************************************************
    # SSL policy configuration
    #*****************************************************************

    # Each policy is configured under a separate namespace, e.g.
    #    dbms.ssl.policy.<policyname>.*
    #
    # The example settings below are for a new policy named 'default'.

    # The base directory for cryptographic objects. Each policy will by
    # default look for its associated objects (keys, certificates, ...)
    # under the base directory.
    #
    # Every such setting can be overridden using a full path to
    # the respective object, but every policy will by default look
    # for cryptographic objects in its base location.
    #
    # Mandatory setting

    #dbms.ssl.policy.default.base_directory=certificates/default

    # Allows the generation of a fresh private key and a self-signed
    # certificate if none are found in the expected locations. It is
    # recommended to turn this off again after keys have been generated.
    #
    # Keys should in general be generated and distributed offline
    # by a trusted certificate authority (CA) and not by utilizing
    # this mode.

    #dbms.ssl.policy.default.allow_key_generation=false

    # Enabling this makes it so that this policy ignores the contents
    # of the trusted_dir and simply resorts to trusting everything.
    #
    # Use of this mode is discouraged. It would offer encryption but no security.

    #dbms.ssl.policy.default.trust_all=false

    # The private key for the default SSL policy. By default a file
    # named private.key is expected under the base directory of the policy.
    # It is mandatory that a key can be found or generated.

    #dbms.ssl.policy.default.private_key=

    # The private key for the default SSL policy. By default a file
    # named public.crt is expected under the base directory of the policy.
    # It is mandatory that a certificate can be found or generated.

    #dbms.ssl.policy.default.public_certificate=

    # The certificates of trusted parties. By default a directory named
    # 'trusted' is expected under the base directory of the policy. It is
    # mandatory to create the directory so that it exists, because it cannot
    # be auto-created (for security purposes).
    #
    # To enforce client authentication client_auth must be set to 'require'!

    #dbms.ssl.policy.default.trusted_dir=

    # Client authentication setting. Values: none, optional, require
    # The default is to require client authentication.
    #
    # Servers are always authenticated unless explicitly overridden
    # using the trust_all setting. In a mutual authentication setup this
    # should be kept at the default of require and trusted certificates
    # must be installed in the trusted_dir.

    #dbms.ssl.policy.default.client_auth=require

    # It is possible to verify the hostname that the client uses
    # to connect to the remote server. In order for this to work, the server public
    # certificate must have a valid CN and/or matching Subject Alternative Names.

    # Note that this is irrelevant on host side connections (sockets receiving
    # connections).

    # To enable hostname verification client side on nodes, set this to true.

    #dbms.ssl.policy.default.verify_hostname=false

    # A comma-separated list of allowed TLS versions.
    # By default only TLSv1.2 is allowed.

    #dbms.ssl.policy.default.tls_versions=

    # A comma-separated list of allowed ciphers.
    # The default ciphers are the defaults of the JVM platform.

    #dbms.ssl.policy.default.ciphers=

    #*****************************************************************
    # Logging configuration
    #*****************************************************************

    # To enable HTTP logging, uncomment this line
    #dbms.logs.http.enabled=true

    # Number of HTTP logs to keep.
    #dbms.logs.http.rotation.keep_number=5

    # Size of each HTTP log that is kept.
    #dbms.logs.http.rotation.size=20m

    # To enable GC Logging, uncomment this line
    #dbms.logs.gc.enabled=true

    # GC Logging Options
    # see http://docs.oracle.com/cd/E19957-01/819-0084-10/pt_tuningjava.html#wp57013 for more information.
    #dbms.logs.gc.options=-XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationStoppedTime -XX:+PrintPromotionFailure -XX:+PrintTenuringDistribution

    # For Java 9 and newer GC Logging Options
    # see https://docs.oracle.com/javase/10/tools/java.htm#JSWOR-GUID-BE93ABDC-999C-4CB5-A88B-1994AAAC74D5
    #dbms.logs.gc.options=-Xlog:gc*,safepoint,age*=trace

    # Number of GC logs to keep.
    #dbms.logs.gc.rotation.keep_number=5

    # Size of each GC log that is kept.
    #dbms.logs.gc.rotation.size=20m

    # Size threshold for rotation of the debug log. If set to zero then no rotation will occur. Accepts a binary suffix "k",
    # "m" or "g".
    #dbms.logs.debug.rotation.size=20m

    # Maximum number of history files for the internal log.
    #dbms.logs.debug.rotation.keep_number=7

    #*****************************************************************
    # Miscellaneous configuration
    #*****************************************************************

    # Enable this to specify a parser other than the default one.
    #cypher.default_language_version=3.0

    # Determines if Cypher will allow using file URLs when loading data using
    # `LOAD CSV`. Setting this value to `false` will cause Neo4j to fail `LOAD CSV`
    # clauses that load data from the file system.
    #dbms.security.allow_csv_import_from_file_urls=true


    # Value of the Access-Control-Allow-Origin header sent over any HTTP or HTTPS
    # connector. This defaults to '*', which allows broadest compatibility. Note
    # that any URI provided here limits HTTP/HTTPS access to that URI only.
    #dbms.security.http_access_control_allow_origin=*

    # Value of the HTTP Strict-Transport-Security (HSTS) response header. This header
    # tells browsers that a webpage should only be accessed using HTTPS instead of HTTP.
    # It is attached to every HTTPS response. Setting is not set by default so
    # 'Strict-Transport-Security' header is not sent. Value is expected to contain
    # dirictives like 'max-age', 'includeSubDomains' and 'preload'.
    #dbms.security.http_strict_transport_security=

    # Retention policy for transaction logs needed to perform recovery and backups.

    # Only allow read operations from this Neo4j instance. This mode still requires
    # write access to the directory for lock purposes.
    #dbms.read_only=false

    # Comma separated list of JAX-RS packages containing JAX-RS resources, one
    # package name for each mountpoint. The listed package names will be loaded
    # under the mountpoints specified. Uncomment this line to mount the
    # org.neo4j.examples.server.unmanaged.HelloWorldResource.java from
    # neo4j-server-examples under /examples/unmanaged, resulting in a final URL of
    # http://localhost:7474/examples/unmanaged/helloworld/{nodeId}
    #dbms.unmanaged_extension_classes=org.neo4j.examples.server.unmanaged=/examples/unmanaged

    # A comma separated list of procedures and user defined functions that are allowed
    # full access to the database through unsupported/insecure internal APIs.
    #dbms.security.procedures.unrestricted=my.extensions.example,my.procedures.*

    # A comma separated list of procedures to be loaded by default.
    # Leaving this unconfigured will load all procedures found.
    #dbms.security.procedures.whitelist=apoc.coll.*,apoc.load.*

    #********************************************************************
    # JVM Parameters
    #********************************************************************

    # G1GC generally strikes a good balance between throughput and tail
    # latency, without too much tuning.
    dbms.jvm.additional=-XX:+UseG1GC

    # Have common exceptions keep producing stack traces, so they can be
    # debugged regardless of how often logs are rotated.
    dbms.jvm.additional=-XX:-OmitStackTraceInFastThrow

    # Make sure that `initmemory` is not only allocated, but committed to
    # the process, before starting the database. This reduces memory
    # fragmentation, increasing the effectiveness of transparent huge
    # pages. It also reduces the possibility of seeing performance drop
    # due to heap-growing GC events, where a decrease in available page
    # cache leads to an increase in mean IO response time.
    # Try reducing the heap memory, if this flag degrades performance.
    dbms.jvm.additional=-XX:+AlwaysPreTouch

    # Trust that non-static final fields are really final.
    # This allows more optimizations and improves overall performance.
    # NOTE: Disable this if you use embedded mode, or have extensions or dependencies that may use reflection or
    # serialization to change the value of final fields!
    dbms.jvm.additional=-XX:+UnlockExperimentalVMOptions
    dbms.jvm.additional=-XX:+TrustFinalNonStaticFields

    # Disable explicit garbage collection, which is occasionally invoked by the JDK itself.
    dbms.jvm.additional=-XX:+DisableExplicitGC

    # Remote JMX monitoring, uncomment and adjust the following lines as needed. Absolute paths to jmx.access and
    # jmx.password files are required.
    # Also make sure to update the jmx.access and jmx.password files with appropriate permission roles and passwords,
    # the shipped configuration contains only a read only role called 'monitor' with password 'Neo4j'.
    # For more details, see: http://download.oracle.com/javase/8/docs/technotes/guides/management/agent.html
    # On Unix based systems the jmx.password file needs to be owned by the user that will run the server,
    # and have permissions set to 0600.
    # For details on setting these file permissions on Windows see:
    #     http://docs.oracle.com/javase/8/docs/technotes/guides/management/security-windows.html
    #dbms.jvm.additional=-Dcom.sun.management.jmxremote.port=3637
    #dbms.jvm.additional=-Dcom.sun.management.jmxremote.authenticate=true
    #dbms.jvm.additional=-Dcom.sun.management.jmxremote.ssl=false
    #dbms.jvm.additional=-Dcom.sun.management.jmxremote.password.file=/absolute/path/to/conf/jmx.password
    #dbms.jvm.additional=-Dcom.sun.management.jmxremote.access.file=/absolute/path/to/conf/jmx.access

    # Some systems cannot discover host name automatically, and need this line configured:
    #dbms.jvm.additional=-Djava.rmi.server.hostname=$THE_NEO4J_SERVER_HOSTNAME

    # Expand Diffie Hellman (DH) key size from default 1024 to 2048 for DH-RSA cipher suites used in server TLS handshakes.
    # This is to protect the server from any potential passive eavesdropping.
    dbms.jvm.additional=-Djdk.tls.ephemeralDHKeySize=2048

    # This mitigates a DDoS vector.
    dbms.jvm.additional=-Djdk.tls.rejectClientInitiatedRenegotiation=true

    #********************************************************************
    # Wrapper Windows NT/2000/XP Service Properties
    #********************************************************************
    # WARNING - Do not modify any of these properties when an application
    #  using this configuration file has been installed as a service.
    #  Please uninstall the service before modifying this section.  The
    #  service can then be reinstalled.

    # Name of the service
    dbms.windows_service_name=neo4j

    #********************************************************************
    # Other Neo4j system properties
    #********************************************************************
    dbms.jvm.additional=-Dunsupported.dbms.udc.source=tarball
    wrapper.java.additional=-Dneo4j.ext.udc.source=docker
    ha.host.data=bdb8b58640ea:6001
    ha.host.coordination=bdb8b58640ea:5001
    dbms.tx_log.rotation.retention_policy=100M size
    dbms.memory.pagecache.size=512M
    dbms.memory.heap.max_size=512M
    dbms.memory.heap.initial_size=512M
    dbms.directories.plugins=/plugins
    dbms.directories.logs=/logs
    dbms.connectors.default_listen_address=0.0.0.0
    dbms.connector.https.listen_address=0.0.0.0:7473
    dbms.connector.http.listen_address=0.0.0.0:7474
    dbms.connector.bolt.listen_address=0.0.0.0:7687
    causal_clustering.transaction_listen_address=0.0.0.0:6000
    causal_clustering.transaction_advertised_address=bdb8b58640ea:6000
    causal_clustering.raft_listen_address=0.0.0.0:7000
    causal_clustering.raft_advertised_address=bdb8b58640ea:7000
    causal_clustering.discovery_listen_address=0.0.0.0:5000
    causal_clustering.discovery_advertised_address=bdb8b58640ea:5000
    HOME=/var/lib/neo4j
    EDITION=community