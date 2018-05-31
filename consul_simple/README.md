# Consul 'Simple'

Stolen [here](https://hariinfo.github.io/notes/Spring-Consul-Kubernetes)

Seems like good example on how to make a Spring Boot app run with Consul on k8s.

Simple ? No TLS etc; for that, see ../consul_tls.

Had some problem with this: NAMESPACE-parameter doesn't resolve to 'default'; resolves to ''; hence consul servers cannot find eachother.

Issue filed: https://github.com/hariinfo/service-c/issues/1