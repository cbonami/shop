# Ambassador Motivation

> [Important: Microservice API Gateway <> Enterprise API Gateway](https://www.getambassador.io/about/microservices-api-gateways)

Many of the typical Spring Cloud components and concerns (Zuul, Hystrix, Ribbon, Eureka or ServiceDiscovery in general, etc) were made for non-Kubernetes, non-Ambassador setups. 
You will find that, in Kubernetes generally, and in Ambassador explicitly, most of these functionalities are implicitly or explicitly taken care of. 
For Java developers this is good news. This means we shouldn’t have to include (and couple our architecture to) things like Netflix OSS Ribbon/Hystrix/Eureka/Tracing libraries.

The shopfront will be accessible on a URI exposed by [Ambassador](https://blog.getambassador.io/).
Ambassador is a distribution of [Envoy API Gateway](https://www.envoyproxy.io/docs/envoy/latest/intro/what_is_envoy) specifically designed for and in Kubernetes. 
Ambassador operates as a specialized control plane to expose Envoy’s functionality as Kubernetes *annotations*, which assures seamless and natural integration with the Kubernetes-idioms, and consequently ease-of-use.
Ambassador no-doubt derives its name from the ['Ambassador' Composite Container Pattern](https://kubernetes.io/blog/2015/06/the-distributed-system-toolkit-patterns/) that highly simplifies access to other network resources by making them available on 'localhost'.

Ambassador offers a [plethora of features and microservice patterns](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/arch_overview) that are very interesting in a Microservice context, but there is some overlap and *potentially* some contention with other (standard) components that we have:
* HashiCorp Consul (not available at time of writing, but upcoming)
* Enterprise API Gateway (same remark)
* MS SQL Server databases running on AWS RDS

Some time will be needed to investigate what to use when, and how things work and fit in eachother. 
For example, some questions that I still have:
* (how) will we combine the multi-datacenter *Service Discovery* of HashiCorp Consul, with the (internal) Service Discovery of Ambassador ? does it even make sense to use Consul for service discovery, or will we simply use it as a config server ?
* How will we replace Hystrix with the *Circuit Breaker* offered by Ambassador ? 
* How does the *Health Checking* of Envoy/Ambassador can be linked to the Spring Boot Actuator health checks ?
* How does Ambassador organize *Distributed Tracing*, a feature that will show really helpful when troubleshooting; how does this work without Zipkin ?
* Do we still *need* a Enterprise API Gateway façade (from a pure API *management* perspective, we *maybe* might) ? can we just plug in to it when it arrives and is imposed on us because we need to advertise our services *also* in that gateway ?
* Where will we run the database engine - inside a kubernetes Pet Set or outside Kubernetes ? Will it be MS SQL Server after all ? 
* etc

To know the reasons why I opted for Ambassador/Envoy, but also for inspiration while answering above questions, have a look at [Microservice Patterns with Envoy sidecar proxy](http://blog.christianposta.com/microservices/00-microservices-patterns-with-envoy-proxy-series/).
The reasons why I want to avoid Spring Cloud (Netflix OSS) as a technology that over-arches and binary-binds all of our microservices for now an forever, can be found [in this talk about avoiding binary dependencies in a microservice architecture](https://www.microservices.com/talks/dont-build-a-distributed-monolith/).
