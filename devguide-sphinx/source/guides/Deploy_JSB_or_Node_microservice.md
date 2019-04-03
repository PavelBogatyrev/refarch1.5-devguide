# Deploying a service in RefArch1.5

**__Note:__ For the PI13.I3 architecture drop, this document is specific to Java Spring Boot and Node.js edge microservces. It will remain so until the RefArch1.5 implementation is far enough along that the document becomes common to all RefArch1.5 supported technologies.**

[Deploying a service in RefArch1.5](#deploying-a-service-in-refarch15)
- [Environments](#environments)
    - [DEV Clusters Info](#dev-clusters-info)
        - [DEV5](#dev5)
        - [Jenkinsfile updates to target the dev environment](#jenkinsfile-updates-to-target-the-dev-environment)
        - [Access](#access)
    - [SANDBOX Cluster Info](#sandbox-cluster-info)
        - [Links](#links)
        - [Access](#access-1)
- [Using Jenkins Pipeline and Hydra (to deploy to dev environment)](#using-jenkins-pipeline-and-hydra-to-deploy-to-dev-environment)
        - [Deployment Manifest [`pipeline/deploymentmanifests/manifest.yaml`]](#deployment-manifest-pipelinedeploymentmanifestsmanifestyaml)
        - [Application Definition File [`applicationDefinition.yaml`]](#application-definition-file-applicationdefinitionyaml)
        - [Stub Services Manifest [`pipeline/stubRunner/servicesManifest.yaml`]](#stub-services-manifest-pipelinestubrunnerservicesmanifestyaml)
- [What happens during deployment](#what-happens-during-deployment)
- [Using Hydra CLI (ONLY use for sandbox environment)](#using-hydra-cli-only-use-for-sandbox-environment)
- [Verifying & Accessing Deployed Service](#verifying--accessing-deployed-service)
- [Generating traffic to deployed services](#generating-traffic-to-deployed-services)
    - [Role of synthetic/live traffic for hydra deployments](#role-of-syntheticlive-traffic-for-hydra-deployments)
    - [Automated traffic generation in the cluster](#automated-traffic-generation-in-the-cluster)
- [Troubleshooting](#troubleshooting)

## Environments
### DEV Clusters Info
#### DEV5
  * Name: **EksJ-VpcA-useast1-DeliveryDevQA-Dev5** -- Note: this is the **DEV5** environment for PI13
  * AWS account: eis-deliverydevqa
  * AWS region: us-east-1
  * [~/.kube/config file](/files/kubeconfig-dev5)
  * Links:
    * Kiali: http://kiali.eksj-useast1.eks.eis-deliverydevqa.cloud.:20001/kiali (username/pwd: admin/admin)
    * Index page with link to other observability tools: http://monitoring.eksj-useast1.eks.eis-deliverydevqa.cloud

#### Jenkinsfile updates to target the dev environment
  * All teams deploying to dev clusters in pi13 must use [medusa:snake:](https://github.com/EBSCOIS/platform.infrastructure.medusa).
  * To setup a Medusa pipeline, teams must adhere to the instructions in the [medusa:snake: README.md](https://github.com/EBSCOIS/platform.infrastructure.medusa#usage).
 
#### Access
  * ADFS-ExReadOnlyRole gives read-only access to the cluster. This would be the default for all teams/devs.
  * Additionally, ADFS-ExAdministratorsRole gives admin access to the cluster. This is for EA/admins to manage the cluster.

### SANDBOX Cluster Info
  * Name: **EksI-VpcA-useast1-DeliveryDevQA-EASandbox** -- Note: this is the **SANDBOX** environment for PI13
  * AWS account: eis-deliverydevqa
  * AWS region: us-east-1
  * [~/.kube/config file](/files/kubeconfig-easandbox)

#### Links
  * Kiali: http://kiali.eksi-useast1.eks.eis-deliverydevqa.cloud:20001 (username/pwd: admin/admin)
  * Index page with link to other observability tools: http://monitoring.eksi-useast1.eks.eis-deliverydevqa.cloud

#### Access
  * ADFS-ExDevTeamRole gives admin access to the cluster. **Please exercise caution when executing commands that could potentially delete resources on this cluster**.
  
## Using Jenkins Pipeline and Hydra (to deploy to dev environment)

Deployment in RefArch 1.5 is done using a Jenkins Pipeline. The [supported Jenkinsfile is described in detail in the medusa:snake: README.md](https://github.com/EBSCOIS/platform.infrastructure.medusa#jenkinsfile)

Medusa pipelines in RefArch 1.5 use pipeline functions from the [Hydra Project](https://github.com/EBSCOIS/platform.infrastructure.hydra) to execute deployments. Medusa and Hydra rely on several files in your repo which specify how and where your project should be deployed. Below are the dependencies a development team deploying services on the RefArch1.5 platform will need to address:

#### Deployment Manifest [`pipeline/deploymentmanifests/manifest.yaml`]
  * This is the default deployment manifest file used by hydra, if an {env-name}.yaml file is not found.
  * For more information on supported stages and customization of this file, please refer to: [Hydra Deployment Manifest](https://github.com/EBSCOIS/platform.infrastructure.hydra/wiki/Deployment-Manifest)

#### Application Definition File [`applicationDefinition.yaml`]
  * This file is required for tagging resources for cost appropriation and Cloudability reporting.
  * It also provides certain pipeline specific input data.
  * The file should conform to the [application definition description in the medusa:snake: README.md](https://github.com/EBSCOIS/platform.infrastructure.medusa#application-definition-file)
  
#### Stub Services Manifest [`pipeline/stubRunner/servicesManifest.yaml`]
  * **NOT applicable to Java Spring Boot services, which manage stubs natively through Gradle**
  * This is a simple key:value manifest, which lists your runtime service dependencies and their Spring Cloud Contract stub artifacts (generated from Contract tests in the provider project)
  * VALUE is the stub name in Artifactory
  * KEY is an arbitrary name, consisting of upper-case letters, digits and underscores, for referring to the service dependency in your application code. During integration/contract testing, Medusa will spin up each stub and provide its location to your application via an environment variable in the form of `[KEY]_ORIGIN`.
  * Please refer to the node-express-cookiecutter project for an example of [the manifest](https://github.com/EBSCOIS/platform.shared.node-express-cookiecutter/blob/master/pipeline/stubRunner/servicesManifest.yaml) and how one might [utilize the env var in application code](https://github.com/EBSCOIS/platform.shared.node-express-cookiecutter/blob/master/src/services/example-service/index.js#L1)

## What happens during deployment

The following resources are created, for the microservice, by Hydra as part of the hydra prepare and deploy commands:

**Kubernetes resources/controllers**  
  * [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
  * [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
  * [horizontal-pod-autoscaler aka. hpa](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
  * [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)

**Istio resources**
  * [VirtualService](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#VirtualService)
  * [DestinationRule](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#DestinationRule)
  
## Using Hydra CLI (ONLY use for sandbox environment)

Projects deployed into DevQA use a pipeline as described above to automate deployment.

## Verifying & Accessing Deployed Service

A VirtualService is automatically created for the deployed application, to allow routing requests to the application pods/containers. The hosts that are allowed to access the service by default are of the format *service-name.external-dns-hosted-zone-for-cluster*. 

For example, if the service 'simplemiddle' is deployed to the cluster with dns entry eksj-useast1.eks.eis-deliverydevqa.cloud, you can access the endpoint /simplemiddle/search via curl as follows:
curl -HHost:simplemiddle.eksj-useast1.eks.eis-deliverydevqa.cloud http://istio.eksj-useast1.eks.eis-deliverydevqa.cloud/simplemiddle/search?q=moon

Note that you are using the -H host header with the request - this is to allow the test client to impersonate the DNS binding for that host and access the service.

## Generating traffic to deployed services
### Role of synthetic/live traffic for hydra deployments
* If a previous version of the service is already present in the cluster, hydra deploy will automatically attempt the canary stage 
* The metrics generated from any real/live traffic are used to validate the health of the deployment
* Here is the default configuration for the canary stage in hydra's deployment manifest:
  ```
  Stages:
  - Type: Canary
    Duration: 1m
    Weight: 30

  - Type: Canary
    Duration: 1m
    Weight: 70

  Validation:
    MinimumSamples: 50
    Metrics:
    - Type: Error
      PercentErrors: 5
      PercentIncrease: 1

    - Type: Performance
      Duration: 1000
      PercentIncrease: 5
  ```

* To summarize:
  * No synthetic/real traffic is needed for  the **first deployment** of a service
  * **2nd and all subsequent deployments** require synthetic/real traffic to generate metrics for the validations at the canary stage

### Automated traffic generation in the cluster
* To address this requirement for metrics-driven deployments and automated promotion, as well as a means to proactively run passive health checks for deployed services, we have a `loadgens3` application running in the cluster.

  **NOTE: This is a *beta* implementation to assist with traffic generation in the cluster and the workflow will likely be further refined as the 1.5 platform evolves.**

* How does `loadgens3` work?
  * This is a simple python application, which has been dockerized to run in the kubernetes cluster
  * The application's repo can be found here: [platform.infrastructure.ekscluster-loadgen-s3](https://github.com/EBSCOIS/platform.infrastructure.ekscluster-loadgen-s3)
  * `loadgens3` loops through a list of urls from an `s3 bucket` every 5 seconds, to generate light traffic against deployed services in the cluster.
  * An API exists via API Gateway, that calls lambda functions to update the S3 bucket.

* How do teams use `loadgens3` app to help generate traffic for their service?
  * To add an endpoint for your service in order to generate steady, light traffic against it in the cluster, you have 2 options:
      1. You can use the `PATCH` operation against the `/url` path in this swagger-ui endpoint http://loadgen.eis-deliverydevqa.cloud/, with the following payload:
      ```
        {
        "service-name": "string",
        "service-url": "string"
        }
      ```
      2. You can make a `CURL` command directly to the API gateway endpoint like this:
      ```
        curl -X PATCH \
          https://wfasyphdjb.execute-api.us-east-1.amazonaws.com/beta/url \
          -H 'Cache-Control: no-cache' \
          -H 'Content-Type: application/json' \
          -d '{"service-url" :"http://istio.eksj-useast1.eks.eis-deliverydevqa.cloud", "service-name" : "EBSCONEXT-UI"}'
      ```
  * Please see the  [loadgens3 repo#readme](https://github.com/EBSCOIS/platform.infrastructure.ekscluster-loadgen-s3/blob/master/README.md) for more information.

  * To monitor the activity against your service, you can utilize the various [Observability](/guides/Observability.md) dashboards/tools, as well as review the logs on the `loadgens3` container using this command:
    `k logs -f --tail=100 deployment/loadgens3`
  
  * **NOTE**: This action will only be required *once* for a service, unless the endpoint changes. Once your service endpoint has been added i.e., after the 1st deployment, subsequent deployments will be able to use the metrics generated out of this activity for canary deployments and no further action is needed for traffic generation.

## Troubleshooting  

* If the hydra deploy command fails (cli or jenkins-based) due to an unhandled exception, there may be orphaned deployments/other k8s and Istio resources in the cluster that would need to be cleaned up manually. Please contact EA to help reset these.

* Please contact EA on the [RefArch1.5 Chat Set - Troubleshooting Channel](https://teams.microsoft.com/l/channel/19%3aa2a0927486e74b35bbd033a54fc5495c%40thread.skype/Troubleshooting?groupId=9b1ce806-0126-471c-8e35-77b3115110e6&tenantId=50fa36ca-7dd3-44f1-9e3f-1bf39a3963a5) if this happens to help diagnose the failure scenario and identify next steps. You can @mention [Aish](abhavan@ebsco.com), [Nate](nbaechtold@ebsco.com) & [Seshu](spasam@ebsco.com) to get someone to look into it quickly.
