# Local Development and Debugging in RefArch 1.5

<!-- TOC -->

- [Local Development and Debugging in RefArch 1.5](#local-development-and-debugging-in-refarch-15)
    - [Development Tools for RefArch 1.5](#development-tools-for-refarch-15)
        - [Common Environment Setup](#common-environment-setup)
        - [Microservices](#microservices)
        - [UI + edge](#ui--edge)
        - [Debugging](#debugging)
    - [Debugging Deployed Services](#debugging-deployed-services)

<!-- /TOC -->

## Development Tools for RefArch 1.5

### Common Environment Setup
* Python >= 2.7.15
* AWS Authentication
* `aws-iam-authenticator`
* [aws-adfs](https://github.com/venth/aws-adfs) should be setup to use `kublectl`. 
    * [Detailed Instructions](http://confluence/display/TCO/Using+aws-adfs+for+AWS+cli+access+using+single+sign+on)
* Artifactory Access
* Kubernetes Config
* [Kubectl](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html)
* Git
* [Docker latest](https://www.docker.com/get-started) (optional)

### Microservices
* [OpenJDK 11.x](http://openjdk.java.net/projects/jdk/11/)
* Artifactory Authentication – gradle.properties

### UI + edge            
* [NodeJS 8.x LTS](https://nodejs.org/en/) (End of Octobose 2018 will switch to 10.x LTS)
* Artifactory Authentication - npmrc
* Npm >= 6
* Yeoman

### Debugging 
* Visual Studio Code with [Kubernetes plugin](https://github.com/Azure/vscode-kubernetes-tools) (optional)
* [telepresence](https://www.telepresence.io/reference/install) (optional)

## Debugging Deployed Services

Telepresense can be used to troubleshoot services deployed in Kubernetes cluster. Traffic to a POD can be hijacked and routed to developer machine (preview environment only).

For example:

`telepresence --swap-deployment hello-world --run gradle bootRun`

Above command will run `gradle bootRun` and forward traffic destined for `hello-world` to local machine.

Telepresense creates secure tunnel between developer machine and Kubernetes cluster. When running, developer can seamlessly resolve and access Kubernetes services

Useful scenarios:
* [Debug a Kubernetes service locally](https://www.telepresence.io/tutorials/kubernetes)
* [Connect to a remote Kubernetes cluster](https://www.telepresence.io/tutorials/kubernetes-client)
* [Rapid development with Kubernetes](https://www.telepresence.io/tutorials/kubernetes-rapid)