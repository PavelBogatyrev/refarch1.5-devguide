# Troubleshooting

<!-- TOC -->

- [Troubleshooting](#troubleshooting)
- [Github Autowire](#github-autowire)
  - [Symptoms](#symptoms)
  - [Solution](#solution)
- [Crash Loop Detection](#crash-loop-detection)
  - [Symptoms](#symptoms-1)
  - [Solution](#solution-1)
    - [Walkthrough](#walkthrough)
- [sudo: no tty present and no askpass program specified](#sudo-no-tty-present-and-no-askpass-program-specified)
  - [Symptoms](#symptoms-2)
  - [Solution](#solution-2)
  - [Walkthrough](#walkthrough-1)
- [Service is slow or crashing/restarting while running a performance or load test](#service-is-slow-or-crashingrestarting-while-running-a-performance-or-load-test)
  - [Symptoms](#symptoms-3)
  - [Solution](#solution-3)
    - [Walkthough:](#walkthough)

<!-- /TOC -->

# Github Autowire

## Symptoms
Project or Repository does not appear in the Jenkins-Refarch15a Server despite having the jenkins-refarch15a label.

## Solution
In the event that a repository does not show up in the Jenkins-RefArch15a server, please confirm:
1. https://infrastructure.eis-platformlive.cloud webhook exists in your repository. 
    (Webhook configured to send only Label Events)
2. https://jenkins-refarc15a-public.eis-platformlive.cloud webhook exists in your repository
    (Webhook configured to send Pull Requests and Pushes)
3. jenkins-refarch15a label exists and is correctly spelt in your repository.
DELETE label jenkins-refarch15a and then CREATE it again. Do not edit the existing label.



# Crash Loop Detection

Crash loop detection is a feature within hydra that will fail your pipeline build if your service's container fails to start or crashes during startup.

## Symptoms
You will see something similar to this in the Jenkins log for your project:

```
2018-10-15 14:33:51 Staging pods...
2018-10-15 14:33:52 Deployment ebsconext-edge-04cc528 found. Updating...
2018-10-15 14:33:52 Service ebsconext-edge found. Updating...
2018-10-15 14:33:52 ConfigMap ebsconext-edge-04cc528-config found. Updating...
2018-10-15 14:33:52 Horizontal Pod Autoscaler ebsconext-edge-hpa found. Updating...
2018-10-15 14:33:52 complete
2018-10-15 14:33:52 Running crashloop detection...
2018-10-15 14:33:53 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:33:58 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:03 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:08 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:13 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:18 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:23 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:28 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:33 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:38 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:44 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:49 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:54 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:34:59 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:35:04 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:35:09 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:35:14 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:35:19 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:35:24 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:35:30 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:35:35 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:35:40 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:35:45 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:35:50 Replica Status(Desired: 1, Current: None, Updated: 1, Available: None, Unavailable: 1)
2018-10-15 14:35:55 Deploy ebsconext-edge-04cc528 Not Successful: None pods available
2018-10-15 14:35:55 completed crashloop detection
2018-10-15 14:35:55 In a crashloop. Aborting...
2018-10-15 14:35:55 Rolling back version 04cc528...
```
## Solution
First, you will need to ensure that your service is passing its health checks (Liveness Probe).  If it is passing them then you will want to retrive the logs from your service to figure out why it is not starting.  You can get them by using the `kubectl logs -n application' command.

### Walkthrough
1. Rerun your Jenkins build and watch the console output for the line `Staging pods...`
2. Run `kubectl get pods -n application`
3. Find one of the failed pods by its name.  The naming convention is `<Service Name>-<Version>-<UniqueID>`. 
    * An example pod name from the above jenkins log would be: `ebsconext-edge-04cc528-847ff5c57f-bfp7w`
4. Run `kubectl describe pod -n application <PodName>` to see if your pod's health checks are failing or are misconfigured.
    * Example: `kubectl describe pod -n application ebsconext-edge-04cc528-847ff5c57f-bfp7w`
    * If you see text indicating that a Liveness probe has failed then you must update your deployment manifest to include a Liveness check that returns a HTTP status 200 code [Liveness Checks](https://github.com/EBSCOIS/platform.infrastructure.hydra/wiki/Deployment-Manifest#service-health-policy-optional)
    * Failed Liveness Check Example:
        ```Warning  Unhealthy              6m (x3 over 6m)  kubelet, ip-10-25-230-114.ec2.internal  Liveness probe failed:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                        Dload  Upload   Total   Spent    Left  Speed
        0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0curl: (7) Failed to connect to localhost port 8081: Connection refused
        Warning  Unhealthy  6m (x9 over 6m)  kubelet, ip-10-25-230-114.ec2.internal  Readiness probe failed:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                        Dload  Upload   Total   Spent    Left  Speed
        0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0curl: (7) Failed to connect to localhost port 8081: Connection refused
        Warning  BackOff  1m (x4 over 2m)  kubelet, ip-10-25-230-114.ec2.internal  Back-off restarting failed container
        ```
5. Run `kubectl logs -n application <Pod Name> <Container Name>`
    * Example: `kubectl logs -n application ebsconext-edge-04cc528-847ff5c57f-bfp7w ebsconext-edge`
    * Use the application logs to diagnose why the container will not start.
6. If there are no application logs or the output indicates a general kubernetes error then run `kubectl describe pod -n application <PodName>` and start a chat on the Troubleshooting RefArch 1.5 Chat Set including the output of this command.


# sudo: no tty present and no askpass program specified

## Symptoms
You recieve an error in your Jenkins build indicating an error similar to `sudo: no tty present and no askpass program specified`.
```
++ id -u
+ sudo chown -R 501 .
sudo: no tty present and no askpass program specified
```

## Solution
The use of sudo is no longer supported on Jekins slaves.  It must be removed from your Jenkinsfile in order for you build to run.

## Walkthrough
Below is an example removeing the use of sudo from a Java microservice Jenkinsfile.

**Before:**
```
#!Groovy
@Library("platform.infrastructure.pipelinelibrary@refarch1.5-current") _

node(platformDefaults.getBuildNodeLabel()) {

  def ecrRegistry = platformDefaults.getDockerRegistry()

  stage("Checkout") {
    sh "sudo rm -rf build .gradle"
    deleteDir()
    checkout scm
  }

  stage("Pull Build Image") {
    def credentials = platformDefaults.getCredentialsId()
    def region = platformDefaults.getRegion()

    docker.withRegistry("https://${ecrRegistry}", "ecr:${region}:${credentials}") {
      docker.image("platform/images/gradle").pull()
    }
  }

  stage('Build') {
    sh """
    docker run --rm -v \$HOME/.gradle/gradle.properties:/home/gradle/.gradle/gradle.properties:ro -v \$WORKSPACE:/home/gradle:rw -u root ${ecrRegistry}/platform/images/gradle clean assemble test
    sudo chown -R \$(id -u) .
    """
  }

  dockerBuildPush()
```

**After:**
```
#!Groovy
@Library("platform.infrastructure.pipelinelibrary@refarch1.5-current") _

node(platformDefaults.getBuildNodeLabel()) {

  def ecrRegistry = platformDefaults.getDockerRegistry()

  stage("Checkout") {
    deleteDir()
    checkout scm
  }

  stage("Pull Build Image") {
    def credentials = platformDefaults.getCredentialsId()
    def region = platformDefaults.getRegion()

    docker.withRegistry("https://${ecrRegistry}", "ecr:${region}:${credentials}") {
      docker.image("platform/images/gradle-refarch15a").pull()
    }
  }

  stage('Build') {
    sh "docker run --rm -v \$HOME/.gradle/gradle.properties:/home/gradle/.gradle/gradle.properties:ro -v \$WORKSPACE:/opt/ebsco:rw ${ecrRegistry}/platform/images/gradle-refarch15a clean assemble test"
  }

  dockerBuildPush()
}

withNodeWrapper(platformDefaults.getDeployNodeLabel()) {
  hydraPreview deployEnv: "dev", instances: 1
  hydraDeploy deployEnv: "dev", instances: 1, namespace: 'application'
```

# Service is slow or crashing/restarting while running a performance or load test

## Symptoms
You are running a performance test, load test or generating a significant amount of traffic for your service and it is not performing well or is crashing and restarting often.

## Solution
One possible cause is having improper resource requests and limits set for your pod.  

  * A resource request tells the kubernetes scheduler how much CPU and memory that your pod will normally use to run.  If you underestimate your resource request then your pod may not receive the resources that it needs in order to operate properly and may be contending for resources with other pods.  Additionally, when a kubernetes node is under resource pressure it will evict pods that are using more resources then they requested before other pods.
  * A resource limit will limit the resources that your pod uses in order to protect the environment from excessive resource consumption.  It is a best practice to have limits on all pods to help kubernetes balance resource appropriately.  A CPU limit will throttle the maximum CPU consumption of your pod while a memory limit will restart you pod when exceeded.

CPU resources are measured in millicores (1000 millicores = 1 CPU core) and memory resources can be measured in units of memory.  

You can see how kubernetes guarantees resources in the following [article](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/).  

There are 3 classes of resource QoS in kubernetes:
* **Best Effort:** If your pod has no resource requests or limits then kubernetes will make a best effort to give your pod resources but will not guarantee anything.
* **Burstable:** A burstable pod means that it has resource requests that are lower than the limits.  Kubernetes will guarantee the resource requests and make a best effort to provide resources up to the resource limits.
* **Guaranteed:**  A guaranteed pod means that it has both resource requests and limits and that the values for both are identical.  Kubernetes will then guarantee those resources to that pod.

### Walkthough:

You can see if you are exceeding your resource requests or limits by querying Prometheus.  In the future, this capability will be available in Grafana.

To see if you are exceeding your CPU or memory requests:
1. Go to [prometheus](http://prometheus.ekse-useast1.eks.eis-deliverydevqa.cloud:9090).
2. The following query will tell you the difference between how many millicores your service is using compared to the amount that it has requested.  A negative value indicates using fewer resources than requested while a positive value indicates using more than requested.  
    * `(sum(rate(container_cpu_usage_seconds_total{namespace="application", pod_name=~"ebsconext-ui.*"}[30m])) by (pod_name) - on (pod_name) label_replace(sum(kube_pod_container_resource_requests_cpu_cores{}) by (pod),"pod_name","$1","pod","(.*)")) * 1000`
    * To change the query to look at your service replace the text `ebsconext-ui` in the field `pod_name=~".*ebsconext-ui.*"` to the name of your service.
    * To change the time range for the query (defaults to 30 minutes) change the `[30m]` value to the number of minutes that you desire.
    * Once complete click the execute button
3. The following query will tell you the difference between how many MB of memory your service has requested and how much it is using.  A negative value indicates using fewer resources than requested while a postive value indicates using more than requested.
    * `(sum (avg_over_time(container_memory_usage_bytes{namespace="application", pod_name=~"ebsconext-ui.*"}[30m])) by (pod_name) - on (pod_name) label_replace(sum(kube_pod_container_resource_requests_memory_bytes{}) by (pod),"pod_name","$1","pod","(.*)")) / 1024 / 1024`
    * To change the query to look at your service replace the text `ebsconext-ui` in the field `pod_name=~".*ebsconext-ui.*"` to the name of your service.
    * To change the time range for the query (defaults to 30 minutes) change the `[30m]` value to the number of minutes that you desire.
4. Once you have the correct values from these queries you can update the Resources Policy section of your [deployment-manifest](https://github.com/EBSCOIS/platform.infrastructure.hydra/wiki/Deployment-Manifest) with more accurate values.
