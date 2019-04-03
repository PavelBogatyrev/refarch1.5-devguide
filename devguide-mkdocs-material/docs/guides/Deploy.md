# Deploying a service in RefArch1.5
[Deploying a service in RefArch1.5](#deploying-a-service-in-refarch15)
- [Environments](#environments)
    - [DEV Clusters Info](#dev-clusters-info)
        - [DEV5](#dev5)
        - [Jenkinsfile updates to target the dev environment, for teams NOT USING MEDUSA](#jenkinsfile-updates-to-target-the-dev-environment-for-teams-not-using-medusa)
        - [Access](#access)
    - [SANDBOX Cluster Info](#sandbox-cluster-info)
        - [Links](#links)
        - [Access](#access-1)
- [Using Jenkins Pipeline and Hydra (to deploy to dev environment)](#using-jenkins-pipeline-and-hydra-to-deploy-to-dev-environment)
     - [Deployment Manifest [hydra/default.yaml]](#deployment-manifest-hydradefaultyaml)
     - [Application Definition File [applicationdefinition.yaml]](#application-definition-file-applicationdefinitionyaml)
     - [Jenkinsfile](#jenkinsfile)
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
  * Name: **EksJ-VpcA-useast1-DeliveryDevQA-Dev5** 
  * AWS account: eis-deliverydevqa
  * AWS region: us-east-1
  * [~/.kube/config file](/files/kubeconfig-dev5)
  * Links:
    * Kiali: http://kiali.eksj-useast1.eks.eis-deliverydevqa.cloud:20001/kiali
    * Index page with link to other observability tools: http://monitoring.eksj-useast1.eks.eis-deliverydevqa.cloud

#### Jenkinsfile updates to target the dev environment, for teams NOT USING MEDUSA
  * Use the **@refarch1.5-current** branch of the platform.infrastructure.pipelinelibrary
    * e.g., in jenkinsfile the second line would be:
    * **@Library("platform.infrastructure.pipelinelibrary@refarch1.5-current") _**

#### Access
  * ADFS-ExDevTeamRole gives read-only access to the cluster. This would be the default for all teams/devs.
  * Additionally, ADFS-ExAdministratorsRole gives admin access to the cluster. This is for EA/admins to manage the cluster.

### SANDBOX Cluster Info
  * Name: **EksI-VpcA-useast1-DeliveryDevQA-EASandbox** -- Note: this is the **SANDBOX** environment for PI12
  * AWS account: eis-deliverydevqa
  * AWS region: us-east-1
  * [~/.kube/config file](/files/kubeconfig-easandbox)

#### Links
  * Kiali: http://kiali.eksi-useast1.eks.eis-deliverydevqa.cloud:20001 (username/pwd: admin/admin)
  * Index page with link to other observability tools: http://monitoring.eksi-useast1.eks.eis-deliverydevqa.cloud

#### Access
  * ADFS-ExDevTeamRole gives admin access to the cluster. **Please exercise caution when executing commands that could potentially delete resources on this cluster**.

## Using Jenkins Pipeline and Hydra (to deploy to dev environment)

Deployment in RefArch 1.5 is done using a Jenkins Pipeline specified in a Jenkinsfile in the root of your Git repository. Rather than having dev teams write their own Jenkinsfile (as in RefArch 1.0), a common one will be provided for inclusion into code repositories. This will contain all the necessary stages for build, test, quality gates, canary deployments, etc. and will allow for extension where necessary.

For early access, before the common Jenkinsfiles are available for Java/Spring and Javascript/Node.js, you can use a preliminary pipeline (like the one specified below) to orchestrate deployment of microservices to RefArch1.5 DevQA infrastructure i.e., Kubernetes + Istio.

Pipelines in RefArch 1.5 use pipeline functions from the [Hydra Project](https://github.com/EBSCOIS/platform.infrastructure.hydra) to execute deployments. Hydra relies on several files in your repo which specify how and where your project should be deployed. Below are the dependencies a development team deploying services on the RefArch1.5 platform will need to address to use the hydra functions in their pipeline:

#### Deployment Manifest [hydra/default.yaml]
  * This is the default deployment manifest file used by hydra, if an {env-name}.yaml file is not found.
  * For more information on supported stages and customization of this file, please refer to: [Hydra Depolyment Manifest](https://github.com/EBSCOIS/platform.infrastructure.hydra/wiki/Deployment-Manifest)

#### Application Definition File [applicationdefinition.yaml]
  * This file is required for tagging resources for cost appropriation and cloudability reporting.
  * The file should have the following key-value pairs at minimum:
    Microservice:
        Market        : training
        Domain        : platform
        Application   : bookprovider
        Team          : paws.ea
    For valid values for these tags, please refer to: [Application Metadata Definition](https://github.com/EBSCOIS/platform.shared.cloud.applicationmetadata/blob/master/metadataDefinition.yaml)

#### Jenkinsfile
  * Add the following stages to the Jenkinsfile to deploy to refarch 1.5 (replacing the current deploy stages)

    **hydraPreview()**
      * this step applies to feature branches only, not executed on master.
      * the feature branches will need to have an open PR for preview to work.
      * the link to the preview environment is posted as a comment on the open PR in github.

    **hydraDeploy deployEnv: "dev"**
      * this step applies ONLY to the master branch, not executed on feature branches.
      * the deployEnv argument determines the target environment where the service is deployed. Hydra looksups the environment-to-eks cluster mapping using this file: [cluster_mapping.yaml](https://github.com/EBSCOIS/platform.infrastructure.pipelinelibrary/blob/master/resources/com/ebsco/platform/pipelinelibrary/cluster_mapping.yaml)

  * See this sample Jenkinsfile to get started: [Jenkinsfile for a simple SpringBoot service](https://github.com/EBSCOIS/platform.training.bookprovider/blob/istio/Jenkinsfile)



## What happens during deployment

The following resources are created for the microservice, by Hydra as part of the hydraDeploy command:

**Kubernetes resources/controllers**
  * [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
  * [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/_)
  * [horizontal-pod-autoscaler aka. hpa](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
  * [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)

**Istio resources**
  * [VirtualService](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#VirtualService)
  * [DestinationRule](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#DestinationRule)

## Using Hydra CLI (ONLY use for sandbox environment)

Projects deployed into DevQA use a pipeline as above to automate deployment. For the sandbox environment, you can use the Hydra CLI from the command line to perform manual deployments:

  * Get pipenv on your workstatoin, if you do not have it already
  [macOS] sudo pip install pipenv
  * Install hydra as a local package
    * [hydra] pipenv install -e .
  * Run hydra commands
    * [hydra] pipenv run hydra <command> <args>
    * usage: hydra {deploy,preview,teardown,reset,alert} ...
    * example:
    * hydra deploy [-h] [-m MANIFEST] -n NAME -ns NAMESPACE -i IMAGE -v
                    VERSION -e ENV -t TEAM [-c CLUSTER] [-l KEY=VALUE]

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
  * To add an endpoint for your service in order to generate steady, light traffic against it in the cluster, you can do this via the loadgen UI
    > http://loadgen-fe.eksj-useast1.eks.eis-deliverydevqa.cloud
  * The lists of services that it is generating load for are split by cluster.
  * To add a service, select the + from the left menu. Enter the name of your service, the URL that you want traffic directed to and select the cluster from the dropdown. Press Save Configuration to save.
  * You should then see your services in the main page.
  * If you need to delete, find your service in the list, and press the delete button.
  * If you need to amend a service, delete it, then recreate it.
  * Please see the  [loadgens3 repo#readme](https://github.com/EBSCOIS/platform.infrastructure.ekscluster-loadgen-s3/blob/master/README.md) for more information.

  * To monitor the activity against your service, you can utilize the various [Observability](/guides/Observability.md) dashboards/tools, as well as review the logs on the `loadgens3` container using this command:
    `k logs -f --tail=100 deployment/loadgens3`

  * **NOTE**: This action will only be required *once* for a service, unless the endpoint changes. Once your service endpoint has been added i.e., after the 1st deployment, subsequent deployments will be able to use the metrics generated out of this activity for canary deployments and no further action is needed for traffic generation.

## Troubleshooting

* If the hydra deploy command fails (cli or jenkins-based) due to an unhandled exception, there may be orphaned deployments/other k8s and Istio resources in the cluster that would need to be cleaned up manually. Please contact EA to help reset these.

* Please contact EA on the [RefArch1.5 Chat Set - Troubleshooting Channel](https://teams.microsoft.com/l/channel/19%3aa2a0927486e74b35bbd033a54fc5495c%40thread.skype/Troubleshooting?groupId=9b1ce806-0126-471c-8e35-77b3115110e6&tenantId=50fa36ca-7dd3-44f1-9e3f-1bf39a3963a5) if this happens to help diagnose the failure scenario and identify next steps. You can @mention [Aish](abhavan@ebsco.com), [Nate](nbaechtold@ebsco.com) & [Seshu](spasam@ebsco.com) to get someone to look into it quickly.
