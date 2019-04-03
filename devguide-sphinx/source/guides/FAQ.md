# FAQs

[FAQs](#faqs)
- [Windows](#windows)
- [Java](#java)
- [Gradle](#gradle)
- [Eclipse](#eclipse)
- [NodeJS / npm](#nodejs--npm)
- [AWS authentication and tooling](#aws-authentication-and-tooling)
    - [Setup aws-adfs](#setup-aws-adfs)
    - [Setup aws-iam-authenticator](#setup-aws-iam-authenticator)
    - [Setup kube config](#setup-kube-config)
    - [Setup kubectl](#setup-kubectl)
- [Accessing services](#accessing-services)
- [Dev tools](#dev-tools)

## Windows

* Windows 10 is preferred OS
* Make sure `HOME` environment variable is set
    * Open command prompt
    * `echo %HOME%` should display your home directory path

## Java

* **DO NOT** install Oracle JDK
* Install [OpenJDK 11.x](https://jdk.java.net/11/)
    * [macOS instructions](https://stackoverflow.com/questions/52524112/how-do-i-install-openjdk-java-11-on-mac-osx-allowing-version-switching)
    * [Windows instructions](https://stackoverflow.com/questions/52511778/how-to-install-openjdk-11-on-windows)
* All RefArch 1.5 development must use JDK 11.x or current LTS
* `java -version` should print something like the following:
    * `openjdk version "11" ...`

## Gradle

* It is not necessary to install gradle. And gradle tasks should not be invoked using `gradle`.
* Use gradle wrapper to install gradle and run tasks. Examples:
    * `.\gradlew.bat clean assemble`
    * `./gradlew clean assemble`
* Java based microservices must use Gradle version `4.10.2`. `gradle/wrapper/gradle-wrapper.properties` must have:
    * `distributionUrl=https\://services.gradle.org/distributions/gradle-4.10.2-bin.zip`
* Gradle properties must be configured with artifactory information:
    * Windows: `%HOME%\.gradle\gradle.properties`
    * macOS: `$HOME/.gradle/gradle.properties`
    * See `Java` section at the bottom of this [link](http://confluence.epnet.com/display/entarch/Connect+to+Artifactory)
        * `artifactory_user` must be set to `<user>@corp.epnet.com` (change `<user>`)
        * `artifactory_password` must be set to your personal API key from Artifactory
        * `artifactory_contextUrl` must be set to `https://eis.jfrog.io/eis`

## Eclipse

* Install Eclipse IDE for Java Developers Version: `2018-09 (4.9.0)` or better
* If necessary install [Java 11 Support](https://marketplace.eclipse.org/content/java-11-support-eclipse-2018-09-49) extension for Eclipse

## NodeJS / npm

* Install NodeJS LTS version. Currently LTS is `8.12.x`. End of October 2018, NodeJS `10.x` will be LTS
* Install npm `6.4` or better (`npm install npm@latest -g`)
* `npm` configuration must be updated to point to artifactory:
    * Windows: `%HOME%\.npmrc`
    * macOS: `$HOME/.npmrc`
* See `JavaScript` section in this [link](http://confluence.epnet.com/display/entarch/Connect+to+Artifactory). Once configured `.npmrc` must contain:
    * `always-auth` set to `true`
    * `email` set to `<user>@corp.epnet.com` (change `<user>`)
    * `registry` set to `https://eis.jfrog.io/eis/api/npm/npm`
    * `_auth` token **MUST NOT** be set to API key. See `Steps to generate _auth` section in confluence link. Run the `curl` command with user and API token and the output from `curl` command must be set to `_auth` value

## AWS authentication and tooling
### Setup aws-adfs
* [Link to instructions on confluence to setup aws-adfs](http://confluence/display/TCO/Using+aws-adfs+for+AWS+cli+access+using+single+sign+on)
* **NOTE**: Omit the `--profile` argument when setting this up, else the `AWS_PROFILE` env variable will need to be setup to point to the correct profile context for kubectl commands to work.
  * Example:
    * `aws-adfs login --region=us-east-1 --adfs-host=fsx.ebsco.com` will not require `AWS_PROFILE` env variable to be set
    * `aws-adfs login --profile=eis-deliverydevqa --region=us-east-1 --adfs-host=fsx.ebsco.com` will require the `AWS_PROFILE` env variable to be set to `eis-deliverydevqa`
      * For MacOS: `export AWS_PROFILE=eis-deliverydevqa`
      * For Windows: `set AWS_PROFILE=eis-deliverydevqa`

### Setup aws-iam-authenticator
https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html

### Setup kube config
* download or copy [kube config for Dev3 cluster](/files/kubeconfig-dev3)
* `config` file should be located under
  * `~/.kube` for MacOS
  * `$HOME/.kube` for Windows
  * verify if the current context is pointing to the correct cluster/environment by using the following commands:
    * `kubectl config current-context`
    * `kubectl config view`

### Setup kubectl
* https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html
* `kubectl` version must be `1.10` or better. Older versions will not work. Run `kubectl version` to check version

## Accessing services

* Access services using the service URL:
    * Run `kubectl get virtualservices` and identify the service name
    * Access the service as: `http://<service name>.<cluster domain>/<context path>/<endpoint>`.
        * Example: `http://arch-ea-platform-training-simplemiddle-tommitchell.eksi-useast1.eks.eis-deliverydevqa.cloud/tommitchell/search?q=moon`

## Dev tools
Nice-to-have dev tools:
* Visual Studio Code
  * add Kubernetes plugin
* [Telepresence](https://www.telepresence.io/reference/install)
