# HAProxy Ingress helm chart

[HAProxy Ingress](https://github.com/jcmoraisjr/haproxy-ingress) is an Ingress controller that uses ConfigMap to store the global haproxy configuration, and ingress annotations to configure per-backend settings.

## Introduction

This chart bootstraps an HAProxy Ingress deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

* Helm 3 installed, see installation instructions [here](https://helm.sh/docs/intro/install/)
* Kubernetes 1.19+ with Beta APIs enabled

## Installing the Chart

To install the latest stable version with the release name `ingress` in the current namespace and using default configurations:

```console
$ helm repo add haproxy-ingress https://haproxy-ingress.github.io/charts
$ helm install ingress haproxy-ingress/haproxy-ingress
```

The [configuration](#configuration) section lists the parameters that can be configured during installation.

Installation tips:

* All resources will be created in the current namespace. Add `--create-namespace --namespace=<ns>` command-line options to install HAProxy Ingress in another one
* The default configuration installs HAProxy Ingress as a deployment, add `--set controller.kind=DaemonSet` command-line option to install as a DaemonSet
* The default service type is `LoadBalancer`, add `--set controller.service.type=<type>` command-line option to change to `ClusterIP` or `NodePort`
* Ingress status will not report the IP address of the service unless you add `--set controller.publishService.enabled=true` command line option
* If the release name is `haproxy-ingress`, the resource names will not add the release name prefix and will have a shorter name
* Chart versions are in sync with minor HAProxy Ingress versions, so:
    * Use eg `--version '~0.8'` command-line option to install the latest `v0.8` release of HAProxy Ingress
    * See available chart and controller versions with `helm search repo haproxy-ingress -l`
    * Add `--devel` command-line option to enable or list non stable versions as well

## Upgrading to a new Chart version

To upgrade the release `ingress` to the latest stable version:

```console
$ helm repo update
$ helm upgrade ingress haproxy-ingress/haproxy-ingress
```

**Upgrade warning:** charts since 0.8.1 changed name patterns and this should break upgrades. It is recommended to uninstall and reinstall the HAProxy Ingress chart - and always test upgrades on a staging environment.

Upgrade tips:

* helm preserve the installation options, eg a `--set controller.service.type=ClusterIP` used when installing the chart doesn't need to be configured when upgrading it
* `--version` and `--devel` also available to point to an older version or a non stable one

## Uninstalling the Chart

To uninstall/delete the `ingress` release:

```console
$ helm delete ingress
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Running in Dual-Stack Mode

To run the HAProxy Ingress in dual-stack mode you will need a Kubernetes cluster that supports dual-stack services (v1.20+ with the `IPv6DualStack` feature gate enabled), and make the following configuration changes:

```yaml
controller:
  config:
    bind-ip-addr-http: "[::]"
    bind-ip-addr-tcp: "[::]"
  service:
    ipFamilyPolicy: RequireDualStack
```

You may need to make additional configuration changes if you have an IPv6-only or IPv6-first dual-stack cluster.

For more information, see the Kubernetes [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/) documentation for instructions on configuring your cluster.

Note that in IPv6-only mode, logging [does not work](https://github.com/haproxy-ingress/charts/issues/15) by default. Enable the external/sidecar HAProxy setting and leave logs disabled to work around this:

```yaml
controller:
  logs:
    enabled: false
  haproxy:
    enabled: true
```

## Configuration

The following table lists the configurable parameters of the HAProxy Ingress chart and their default values.

Parameter | Description | Default
--- | --- | ---
`rbac.create` | If true, create & use RBAC resources | `true`
`rbac.secret.write` | If true, and rbac.create is true, add write access to secrets, used by acme | `false`
`rbac.security.enable` | If true, and rbac.create is true, create & use PSP resources on Kubernetes clusters up to v1.25 | `false`
`serviceAccount.create` | If true, create serviceAccount | `true`
`serviceAccount.name` | ServiceAccount to be used | ``
`serviceAccount.automountServiceAccountToken` | Automount API credentials for the ServiceAccount | `true` |
`controller.automountServiceAccountToken` | Automount API credentials to the controller's pod | `true` |
`controller.name` | name of the controller component | `controller`
`controller.image.repository` | controller container image repository | `quay.io/jcmoraisjr/haproxy-ingress`
`controller.image.tag` | controller container image tag | `v0.14.7`
`controller.image.pullPolicy` | controller container image pullPolicy | `IfNotPresent`
`controller.imagePullSecrets` | controller image pull secrets | `[]`
`controller.extraArgs` | extra command line arguments for the haproxy-ingress-controller | `{}`
`controller.extraEnvs` | extra environment variables for the haproxy-ingress-controller | `[]`
`controller.extraVolumes` | extra volumes for the haproxy-ingress-controller | `[]`
`controller.extraVolumeMounts` | extra volume mounts for the haproxy-ingress-controller | `[]`
`controller.extraContainers` | extra containers that to the haproxy-ingress-controller | `[]`
`controller.initContainers` | extra containers that can initialize the haproxy-ingress-controller | `[]`
`controller.template` | custom template for haproxy-ingress-controller | `{}`
`controller.templateFile` | custom haproxy template path for haproxy-ingress-controller | `""`
`controller.defaultBackendService` | backend service to use if defaultBackend.enabled==false | `""`
`controller.ingressClass` | name of the ingress class to route through this controller | `haproxy`
`controller.ingressClassResource.enabled` | create an [IngressClass](https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class) resource for this controller | `false`
`controller.ingressClassResource.default` | mark the IngressClass as [default](https://kubernetes.io/docs/concepts/services-networking/ingress/#default-ingress-class) for the cluster | `false`
`controller.ingressClassResource.controllerClass` | customizes the [controller name](https://haproxy-ingress.github.io/docs/configuration/command-line/#ingress-class) | `''`
`controller.ingressClassResource.parameters` |  | `{}`
`controller.haproxy.enabled` | set `true` to configure haproxy as a sidecar instead of use the embedded version | `false`
`controller.haproxy.image.repository` | haproxy container image repository, when enabled | `haproxy`
`controller.haproxy.image.tag` | haproxy container image tag | `2.4.26-alpine`
`controller.haproxy.image.pullPolicy` | haproxy container image pullPolicy | `IfNotPresent`
`controller.haproxy.extraArgs` | extra command line arguments for haproxy | `{}`
`controller.haproxy.resources` | haproxy container resource requests & limits | `{}`
`controller.haproxy.lifecycle` | Lifecycle hooks for haproxy container | `{}`
`controller.haproxy.securityContext` | Security context settings for the haproxy container | `{}`
`controller.healthzPort` | The haproxy health check (monitoring) port | `10253`
`controller.legacySecurityContext` | Defines if `controller.securityContext` should be applied to the controller's pod (legacy: true) or container (legacy: false)  | `true`
`controller.livenessProbe.path` | The liveness probe path | `/healthz`
`controller.livenessProbe.port` | The liveness probe port | `10253`
`controller.livenessProbe.failureThreshold` | The livneness probe failure threshold | `3`
`controller.livenessProbe.initialDelaySeconds` | The livneness probe initial delay (in seconds) | `60`
`controller.livenessProbe.periodSeconds` | The livneness probe period (in seconds) | `10`
`controller.livenessProbe.successThreshold` | The livneness probe success threshold | `1`
`controller.livenessProbe.timeoutSeconds` | The livneness probe timeout (in seconds) | `1`
`controller.readinessProbe.path` | The readiness probe path | `/healthz`
`controller.readinessProbe.port` | The readiness probe port | `10253`
`controller.readinessProbe.failureThreshold` | The readiness probe failure threshold | `3`
`controller.readinessProbe.initialDelaySeconds` | The readiness probe initial delay (in seconds) | `10`
`controller.readinessProbe.periodSeconds` | The readiness probe period (in seconds) | `10`
`controller.readinessProbe.successThreshold` | The readiness probe success threshold | `1`
`controller.readinessProbe.timeoutSeconds` | The readiness probe timeout (in seconds) | `1`
`controller.annotations` | Annotations to be added to DaemonSet/Deployment definitions | `{}`
`controller.podAnnotations` | Annotations for the haproxy-ingress-controller pod | `{}`
`controller.podLabels` | Labels for the haproxy-ingress-controller pod | `{}`
`controller.podAffinity` | Add affinity to the controller pods to control scheduling | `{}`
`controller.podSecurityContext` | Security context settings for the haproxy-ingress-controller pod | `{}`
`controller.priorityClassName` | Priority Class to be used | ``
`controller.securityContext` | Security context settings for the haproxy-ingress-controller pod or container, see `controller.legacySecurityContext` | `{}`
`controller.config` | additional haproxy-ingress [ConfigMap entries](https://haproxy-ingress.github.io/docs/configuration/keys/) | `{}`
`controller.customFiles` | Custom files to be mounted in the controller pod(s) | `{}`
`controller.hostNetwork` | Optionally set to true when using CNI based kubernetes installations | `false`
`controller.dnsPolicy` | Optionally change this to ClusterFirstWithHostNet in case you have 'hostNetwork: true' | `ClusterFirst`
`controller.terminationGracePeriodSeconds` | How much to wait before terminating a pod (in seconds) | `60`
`controller.topologySpreadConstraints` | Configures topology spread constraints in the controller pod | `{}`
`controller.lifecycle` | Lifecycle hooks for controller container | `{}`
`controller.kind` | Type of deployment, DaemonSet or Deployment | `Deployment`
`controller.tcp` | TCP [service ConfigMap](https://haproxy-ingress.github.io/docs/configuration/command-line/#tcp-services-configmap): `<port>: <namespace>/<servicename>:<portnumber>[:[<in-proxy>][:<out-proxy>]]` | `{}`
`controller.enableStaticPorts` | Set to `false` to only rely on ports from `controller.tcp` | `true`
`controller.containerPorts.http` | HTTP container port in the controller | `80`
`controller.containerPorts.https` |  HTTPS container port in the controller | `443`
`controller.daemonset.useHostPort` | Set to true to use host ports 80 and 443 | `false`
`controller.daemonset.hostIP` | Change the IP the host ports will bind to | `nil`
`controller.daemonset.hostPorts.http` | If `controller.daemonset.useHostPort` is `true` and this is non-empty sets the hostPort for http | `"80"`
`controller.daemonset.hostPorts.https` | If `controller.daemonset.useHostPort` is `true` and this is non-empty sets the hostPort for https | `"443"`
`controller.daemonset.hostPorts.tcp` | If `controller.daemonset.useHostPort` is `true` use hostport for these ports from `tcp` | `[]`
`controller.updateStrategy` | the update strategy settings | _see defaults below_
`controller.updateStrategy.type` | the update strategy type to use | `RollingUpdate`
`controller.updateStrategy.rollingUpdate.maxUnavailable` | the max number of unavailable controllers when doing rolling updates | `1`
`controller.minReadySeconds` | seconds to avoid killing pods before we are ready | `0`
`controller.replicaCount` | the number of replicas to deploy (when `controller.kind` is `Deployment`) | `1`
`controller.minAvailable` | PodDisruptionBudget minimum available controller pods | `1`
`controller.resources` | controller container resource requests & limits | `{}`
`controller.autoscaling.enabled` | enabling controller horizontal pod autoscaling (when `controller.kind` is `Deployment`) | `false`
`controller.autoscaling.minReplicas` | minimum number of replicas |
`controller.autoscaling.maxReplicas` | maximum number of replicas |
`controller.autoscaling.targetCPUUtilizationPercentage` | target cpu utilization |
`controller.autoscaling.targetMemoryUtilizationPercentage` | target memory utilization |
`controller.autoscaling.customMetrics` | Extra custom metrics to add to the HPA | `[]`
`controller.tolerations` | to control scheduling to servers with taints | `[]`
`controller.affinity` | to control scheduling | `{}`
`controller.nodeSelector` | to control scheduling | `{}`
`controller.publishService.enabled` | Enable 'publishService' or not, ignored if controller.extraArgs.publish-service is set | `false`
`controller.publishService.pathOverride` | Allows overriding of the publish service to bind to, ignored if controller.extraArgs.publish-service is set | `""`
`controller.service.annotations` | annotations for controller service | `{}`
`controller.service.labels` | labels for controller service | `{}`
`controller.service.clusterIP` | internal controller cluster service IP | `nil`
`controller.service.clusterIPs` | list of internal controller cluster service IPs (for dual-stack) | `[]`
`controller.service.externalTrafficPolicy` | If `controller.service.type` is `NodePort` or `LoadBalancer`, set this to `Local` to enable [source IP preservation](https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-type-nodeport) | `Local`
`controller.service.externalIPs` | list of IP addresses at which the controller services are available | `[]`
`controller.service.extraPorts` | list of extra TCP ports that should be added to the controller service | `[]`
`controller.service.ipFamilies` | list of IP families assigned to the service (for dual-stack) | `nil`
`controller.service.ipFamilyPolicy` | represents the dual-stack-ness of the service | `nil`
`controller.service.loadBalancerClass` | The loadBalancerClass of the controller service | `""`
`controller.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`controller.service.loadBalancerSourceRanges` |  | `[]`
`controller.service.httpPorts` | The http ports to open, that map to the Ingress' port 80. Each entry specifies a `port`, `targetPort` and an optional `nodePort`. | `[ port: 80, targetPort: http ]`
`controller.service.httpsPorts` | The https ports to open, that map to the Ingress' port 443. Each entry specifies a `port`, `targetPort` and an optional `nodePort`. | `[ port: 443 , targetPort: https]`
`controller.service.type` | type of controller service to create | `LoadBalancer`
`controller.stats.enabled` | whether to enable exporting stats |  `false`
`controller.stats.port` | The port number used haproxy-ingress-controller for haproxy statistics | `1936`
`controller.stats.hostPort` | The host port number used haproxy-ingress-controller for haproxy statistics | `~`
`controller.stats.service.annotations` | annotations for stats service | `{}`
`controller.stats.service.clusterIP` | internal stats cluster service IP | `nil`
`controller.stats.service.externalIPs` | list of IP addresses at which the stats service is available | `[]`
`controller.stats.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`controller.stats.service.loadBalancerSourceRanges` |  | `[]`
`controller.stats.service.servicePort` | the port number exposed by the stats service | `1936`
`controller.stats.service.type` | type of controller service to create | `ClusterIP`
`controller.metrics.enabled` | If `controller.stats.enabled = true` and `controller.metrics.enabled = true`, Prometheus metrics will be exported |  `false`
`controller.metrics.embedded` | defines if embedded haproxy's exporter should be used | `true`
`controller.metrics.port` | port number the exporter is listening to | `9101`
`controller.metrics.controllerPort` | port number the controller is exporting metrics on | `10254`
`controller.metrics.image.repository` | prometheus-exporter image repository when embedded is `false` | `quay.io/prometheus/haproxy-exporter`
`controller.metrics.image.tag` | prometheus-exporter image tag | `v0.11.0`
`controller.metrics.image.pullPolicy` | prometheus-exporter image pullPolicy | `IfNotPresent`
`controller.metrics.extraArgs` | Extra arguments to the prometheus-exporter |  `{}`
`controller.metrics.resources` | prometheus-exporter container resource requests & limits |  `{}`
`controller.metrics.securityContext` | Security context settings for sidecar metrics container | `{}`
`controller.metrics.service.annotations` | annotations for metrics service | `{}`
`controller.metrics.service.clusterIP` | internal metrics cluster service IP | `nil`
`controller.metrics.service.externalIPs` | list of IP addresses at which the metrics service is available | `[]`
`controller.metrics.service.loadBalancerClass` | The loadBalancerClass of the service | `""`
`controller.metrics.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`controller.metrics.service.loadBalancerSourceRanges` |  | `[]`
`controller.metrics.service.servicePort` | the port number exposed by the metrics service | `9101`
`controller.metrics.service.serviceControllerPort` | the controller port number exposed by the metrics service | `10254`
`controller.metrics.service.type` | type of controller service to create | `ClusterIP`
`controller.serviceMonitor.enabled` | Enable creation of ServiceMonitor (https://coreos.com/operators/prometheus/docs/latest/api.html#servicemonitor). This has effect only when `controller.stats.enabled = true` and `controller.metrics.enabled = true` | `false`
`controller.serviceMonitor.labels` | Additional labels for the ServiceMonitor resource | `{}`
`controller.serviceMonitor.annotations` | Annotations for ServiceMonitor resource | `{}`
`controller.serviceMonitor.honorLabels` | HonorLabels chooses the metric's labels on collisions with target labels | `true`
`controller.serviceMonitor.interval` | Prometheus scrape interval | `10s`
`controller.serviceMonitor.params` | Use extra parameters from Prometheus when requesting metrics | `false`
`controller.serviceMonitor.metrics.metricRelabelings` | Metric relabel configs to apply to samples before ingestion for proxy metric | `[]`
`controller.serviceMonitor.metrics.relabelings` | Relabel configs to apply to samples before ingestion for proxy metric | `[]`
`controller.serviceMonitor.ctrlMetrics.metricRelabelings` | Metric relabel configs to apply to samples before ingestion for controller metric | `[]`
`controller.serviceMonitor.ctrlMetrics.relabelings` | Relabel configs to apply to samples before ingestion for controller metric | `[]`
`controller.logs.enabled` | enable an access-logs sidecar container that collects access logs from haproxy and outputs to stdout | `false`
`controller.logs.image.repository` | access-logs container image repository | `whereisaaron/kube-syslog-sidecar`
`controller.logs.image.tag` | access-logs image tag | `latest`
`controller.logs.image.pullPolicy` | access-logs image pullPolicy | `IfNotPresent`
`controller.logs.extraVolumeMounts` | extra volume mounts for the access-logs container | `[]`
`controller.logs.port` | port used by sidecar logs container | `514`
`controller.logs.probes` | enable tcp based liveness and readiness probes in the log container | `false`
`controller.logs.securityContext` | Security context settings for sidecar logs container | `{}`
`controller.logs.resources` | access-logs container resource requests & limits |  `{}`
`defaultBackend.enabled` | whether to use the default backend component | `false`
`defaultBackend.name` | name of the default backend component | `default-backend`
`defaultBackend.image.repository` | default backend container image repository | `k8s.gcr.io/defaultbackend-amd64`
`defaultBackend.image.tag` | default backend container image repository tag | `1.5`
`defaultBackend.image.pullPolicy` | default backend container image pullPolicy | `IfNotPresent`
`defaultBackend.imagePullSecrets` | default backend pull secrets | `[]`
`defaultBackend.tolerations` | to control scheduling to servers with taints | `[]`
`defaultBackend.affinity` | to control scheduling | `{}`
`defaultBackend.nodeSelector` | to control scheduling | `{}`
`defaultBackend.podAnnotations` | Annotations for the default backend pod | `{}`
`defaultBackend.podLabels` | Labels for the default backend pod | `{}`
`defaultBackend.replicaCount` | the number of replicas to deploy (when `controller.kind` is `Deployment`) | `1`
`defaultBackend.minAvailable` | PodDisruptionBudget minimum available default backend pods | `1`
`defaultBackend.podSecurityContext` | custom POD security context for the default backend | `{runAsNonRoot: true, runAsUser: 65000, runAsGroup: 65000, fsGroup: 65000}`
`defaultBackend.resources` | default backend pod resources | _see defaults below_
`defaultBackend.resources.limits.cpu` | default backend cpu resources limit | `10m`
`defaultBackend.resources.limits.memory` | default backend memory resources limit | `20Mi`
`defaultBackend.service.name` | name of default backend service to create | `ingress-default-backend`
`defaultBackend.service.annotations` | annotations for metrics service | `{}`
`defaultBackend.service.clusterIP` | internal metrics cluster service IP | `nil`
`defaultBackend.service.externalIPs` | list of externalIPs for the defaultBackend service | `[]`
`defaultBackend.service.loadBalancerClass` | The loadBalancerClass of the service | `""`
`defaultBackend.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`defaultBackend.service.loadBalancerSourceRanges` |  | `[]`
`defaultBackend.service.servicePort` | the port number exposed by the metrics service | `1936`
`defaultBackend.service.type` | type of controller service to create | `ClusterIP`
`defaultBackend.securityContext` | custom POD security context for the default backend container | `{runAsNonRoot: true, runAsUser: 65000, runAsGroup: 65000, fsGroup: 65000}`
`defaultBackend.priorityClassName` | Priority Class to be used | ``
