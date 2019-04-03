# Custom Configuration In Eks/Istio Clusters

**Table of Contents**
* [Custom Configuration In Eks/Istio Clusters](#custom-configuration-in-eksistio-clusters)
    * [Background](#background)
    * [How to add custom configuration aka. bring-your-own-yamls](#how-to-add-custom-configuration-aka-bring-your-own-yamls)
* [Ingress and Egress](#ingress-and-egress)
    * [Ingress](#ingress)
    * [Egress](#egress)
* [Troubleshooting](#troubleshooting)

## Background
* By default, teams will have read-only access to the Eks/Istio clusters and all changes/configuration to the cluster will be applied via automation (e.g., Jenkins pipelines for deployment process). 
* Since RefArch1.5 infrastrcuture features are still in the pre-DevReady milestone phase as of PI12, any configuration needed to be applied to the cluster outside of the scope of these pipelines (e.g., ingress or egress routes) will be handled via a GitOps pattern through the [platform.infrastructure.tempkubeconfig](https://github.com/EBSCOIS/platform.infrastructure.tempkubeconfig) repo.

## How to add custom configuration aka. bring-your-own-yamls
* Clone the [platform.infrastructure.tempkubeconfig](https://github.com/EBSCOIS/platform.infrastructure.tempkubeconfig) repo
* Switch to the branch representing the cluster where the change is to be applied e.g., EksI-VpcA-useast1-DeliveryDevQA-EASandbox
* Add the yaml file to the relevant folder using guidance below:
  * bootstrap -- for any configuration that is required to prime the cluster (e.g., emergent design needs for hydra or other infrastructure pipelines)
  * egress -- for any routing configuration to expose applications to services outside the mesh
  * ingress -- for any routing configuration to expose service methods via the istio-ingress endpoint
  * istio -- for any istio-specific configuration
  * tools -- for any tooling-specific configuration 
* Make a PR on the branch (atleast 1 EA approval required)
* Once the PR is approved and merged into the branch, the configuration will be sync'd and applied to the cluster within 5 minutes automatically.

# Ingress and Egress

Ingress and Egress to and from the Kubernetes/Istio service mesh is being built in PI12. For early access, we are providing the following process for adding Istio ingress and egress rules so you can interact with components outside the mesh.

## Ingress
To expose methods within services via the istio-ingress endpoint (gateway url), you will need to update the ingress/global-ingress-vs.yaml file in the gitops repo [platform.infrastructure.tempkubeconfig](https://github.com/EBSCOIS/platform.infrastructure.tempkubeconfig) for the branch that maps to the cluster you are working on e.g., EksI-VpcA-useast1-DeliveryDevQA-EASandbox.
 * Add a [match:] section with a uri-based math (prefix or exact match allowed) that will route to the destination service.
 * Here's a sample file: [ingress/global-ingress-vs.yaml](https://github.com/EBSCOIS/platform.infrastructure.tempkubeconfig/blob/EksI-VpcA-useast1-DeliveryDevQA-EASandbox/ingress/global-ingress-vs.yaml)

## Egress
To expose applications to services that are outside the cluster, you will need the following kubernetes/istio resources applied to the cluster:
  * [ServiceEntry](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#ServiceEntry)
  * [VirtualService](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#VirtualService) *NOTE: VirtualService is required in addition to the ServiceEntry  only for HTTPS connections outside the mesh.*

To add these resources you'll need to add a new yaml file in the gitops repo [platform.infrastructure.tempkubeconfig](https://github.com/EBSCOIS/platform.infrastructure.tempkubeconfig) for the branch that maps to the cluster you are working on e.g., EksI-VpcA-useast1-DeliveryDevQA-EASandbox.[platform.infrastructure.tempkubeconfig]
 * Add k8s resource [kind: ServiceEntry] to allow access to hosts that are external to the mesh
 * Add k8s resource [kind: VirtualService] to associate routes based on SNI values, to external hosts.

Here's a sample configuration for allowing egress traffic to reach eds-api hosts on both port 80 (http) and 443 (https):
[egress-edsapi.yaml in EA-Sandbox cluster](https://github.com/EBSCOIS/platform.infrastructure.tempkubeconfig/blob/EksI-VpcA-useast1-DeliveryDevQA-EASandbox/egress/egress-edsapi.yaml)

For more info, please see the Istio documentation on how to [Control Egress Traffic](https://istio.io/docs/tasks/traffic-management/egress/).

# Troubleshooting
* Please reach out to EA on the [RefArch1.5 Chat Set - Troubleshooting Channel](https://teams.microsoft.com/l/channel/19%3aa2a0927486e74b35bbd033a54fc5495c%40thread.skype/Troubleshooting?groupId=9b1ce806-0126-471c-8e35-77b3115110e6&tenantId=50fa36ca-7dd3-44f1-9e3f-1bf39a3963a5) to help diagnose any issues with this process. You can @mention [Aish](abhavan@ebsco.com), [Nate](nbaechtold@ebsco.com) & [Seshu](spasam@ebsco.com) to get someone to look into it quickly.
