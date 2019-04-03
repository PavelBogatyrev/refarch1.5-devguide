# Code Examples
<!-- TOC -->

- [Code Examples](#code-examples)
    - [Conventions](#conventions)
    - [Middle Service](#middle-service)
    - [Edge Service](#edge-service)
    - [Calling EBSCO Next API](#calling-ebsco-next-api)
    - [Secret Management](#secret-management)
    - [Queues](#queues)
    - [Calling a Database](#calling-a-database)
    - [Propogating headers for distributed tracing](#propogating-headers-for-distributed-tracing)
    - [Pushing custom metrics to Prometheus](#pushing-custom-metrics-to-prometheus)

<!-- /TOC -->

## Conventions
* **SERVICE PORT** 
  * All services will be exposed on port **8080** (java, nodejs edge & ui).
* **SERVICE NAME**
  * Service names should not include dots, as this will interfere with the DNS-based resolution in the Kubernetes cluster.
  * Must be a DNS 952 label (at most 24 characters, matching regex [a-z]([-a-z0-9]*[a-z0-9])?): e.g. "my-name"
* **SERVICE DISCOVERY**
  * Services will use Kubernetes DNS resolution to discover its dependencies.
  * All services are assigned a DNS A record for a name of the form **my-svc.my-namespace.svc.cluster.local**. This resolves to the cluster IP (or to the set of IPs of the pods selected by the Service in the case of headless services) of the Service. 
    * Example: 
      * To discover a serrvice called 'bookProvider' running on port 8080 in the cluster in the 'default' namespace, the consumer service (bookConsumer) will use the endpoint http://bookprovider:8080 as the baseUrl.
      * To discover a serrvice called 'bookProvider' running on port 8080 in the cluster in the 'application' namespace, the consumer service (bookConsumer) will use the endpoint http://bookprovider.application.svc.cluster.local:8080 as the baseUrl.

## Middle Service
[ea.shared.simplemiddle - refarch-1.5-with-springboot-2 branch](https://github.com/EBSCOIS/ea.shared.simplemiddle/tree/refarch-1.5-with-springboot-2)

[platform.training.bookprovider - istio branch](https://github.com/EBSCOIS/platform.training.bookprovider/tree/istio)

## Edge Service
[ea.shared.simpleedge - refarch-1.5 branch](https://github.com/EBSCOIS/ea.shared.simpleedge/tree/refarch-1.5)

## Calling EBSCO Next API
See auth workflows in common/models/search.js of this repo:
[discover.edspoc.edgeapi](https://github.com/EBSCOIS/discover.edspoc.edgeapi)

## Secret Management
* See /config/secrets/edsapi-secrets.json and /server/lib/auth.js for how secrets are propogated in this repo:
[discover.edspoc.edgeapi](https://github.com/EBSCOIS/discover.edspoc.edgeapi)
* Long-term this will be handled via Hashicorp Vault and the docs will be updated to reflect that.

## Queues
TBD

## Calling a Database
TBD

## Propogating headers for distributed tracing

### With Node.js/Express middleware

```js
// middleware.js
const axios = require("axios");

const headersToPropagate = [
  "x-request-id",
  "x-b3-traceid",
  "x-b3-spanid",
  "x-b3-parentspanid",
  "x-b3-sampled",
  "x-b3-flags",
  "x-ot-span-context"
];

module.exports = (req, res, next) => {
  req.axios = axios.create({
    headers: headersToPropagate.reduce((acc, header) => {
      const val = req.get(header);
      if (val) {
        acc[header] = val;
      }
      return acc;
    }, {})
  });
  next();
};
```

```js
// server.js
const express = require("express");
const app = express();
app.use(require("./middleware"));

app.get("/api/foo", (req, res) => {
 // Make an outbound call to mid-tier using the Axios instance provided by middleware
 req.axios.get("http://somemiddleservice:8080")
  .then(({data}) => res.json(data))
  .catch(err => res.status(500).json({ message: "Hit an error!" });
});
```

## Pushing custom metrics to Prometheus
TBD
