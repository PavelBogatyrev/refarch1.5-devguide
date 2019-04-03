# RefArch 1.5 Platform Release Notes

**NOTE: Please refer to the [Troubleshooting Guide](Troubleshooting_Guide.md) for the resolution of common issues.**

- [RefArch 1.5 Platform Release Notes](#refarch-15-platform-release-notes)
  - [PI13 I5 Platform Upgrade](#pi13-i5-platform-upgrade)
    - [OVERVIEW](#overview)
    - [DEPRECATIONS/CHANGES](#deprecationschanges)
      - [New cluster](#new-cluster)
      - [JSB application.yml changes](#jsb-applicationyml-changes)
      - [Node PDK upgrade](#node-pdk-upgrade)
      - [New Jenkins Server (refarch15e) for services that use Medusa ONLY](#new-jenkins-server-refarch15e-for-services-that-use-medusa-only)
      - [New Secrets Retrieval Mechanism for using VAULT](#new-secrets-retrieval-mechanism-for-using-vault)
    - [NEW FEATURES](#new-features)
      - [Gradle plugins and 5.2.1 upgrade](#gradle-plugins-and-521-upgrade)
      - [Put secrets in SSM Parameter Store using vault UI](#put-secrets-in-ssm-parameter-store-using-vault-ui)
    - [BUG FIXES](#bug-fixes)
      - [NPM audit](#npm-audit)

## PI13 I5 Platform Upgrade

To review release notes for the previous platform upgrades, please see [archived-release-notes](archived-release-notes/).

### OVERVIEW

- **New cluster**: EksJ becomes EksK
- **JSB application.yml**: All JSB services should delete indicated sections from config
- **JSB Gradle upgrade and plugins changes**: All JSB services should make indicated dependency changes
- **Node PDK upgrade**: All Node services should update to latest version of the PDK
- **New Jenkins server** [jenkins-refarch15e](https://jenkins-refarch15e.eis-platformlive.cloud) for medusa-based projects.
- **Baseline Alerts**: All services will now have baseline alerts configured


### DEPRECATIONS/CHANGES

#### New cluster

`EksK-VpcA-useast1-DeliveryDevQA-Dev6`. Kube config file available [here](../files/kubeconfig-dev6)

Monitoring tools page: http://monitoring.eksk-useast1.eks.eis-deliverydevqa.cloud

#### JSB application.yml changes

JSB repositories should have several items removed from `src/main/resources/application.yml`.  A large portion of these settings are now managed by the PDK.  Others are no longer in use.  If a block no longer contains items after removal, remove the block as well. (This may be the case for `server`, `info`, `logging` and `management`.)

Remove the following configuration from `application.yml`:

```diff
spring:
  application:
    name: platform.training.example  # your name
  main:
    banner-mode: "off"

- server:
-  port: 8080
-
application:
  team: ea          # your team
  market: training  # your market
  domain: platform  # your domain
-  subenv: ${APP_SUB_ENV:subenv}
-  environment: ${AWS_ENV:environment}
-  containerId: ${HOSTNAME:container}
-  transactionIdHeader: "TRANSACTION_ID"
-
- info:
-  title: ${spring.application.name}
-  market: ${application.market}
-  domain: ${application.domain}
-  version: ${APP_VERSION:unknown}
-  environment: ${AWS_ENV:environment}
-  containerId: ${HOSTNAME:container}
-
- logging:
-  level:
-    root: INFO
-
- management:
-  server:
-    port: 8081
-  endpoints:
-    web:
-      exposure:
-        include: env,health,info,metrics,prometheus,threaddump
-      base-path: /admin
-      path-mapping:
-        prometheus: prometheus
-  endpoint:
-    metrics:
-      enabled: true
-    prometheus:
-      enabled: true
-  metrics:
-    export:
-      prometheus:
-        enabled: true

```

#### Node PDK upgrade

An important patch release has been made available and all Node services should ugprade; this is a non-breaking change that will align services to changes in platform-level metrics collection, so all that is required is to do an npm install:

`npm i --save platform.shared.node-express-pdk@2.0.2`

Please make sure to commit the resulting changes in both the package.json and package-lock.json files to SCM.

#### New Jenkins Server (refarch15e) for services that use Medusa ONLY

**NOTE: Jenkins server jenkins-refarch15d will be decommissioned at the end of I6, if your project is on jenkins-refarch15d, it needs to be migrated to jenkins-refarch15e**

- If you are **not** using / migrating to [Medusa], you should continue to use the `refarch15a` Jenkins instance & label
- The new Jenkins server is located at: https://jenkins-refarch15e.eis-platformlive.cloud
- To move your job from https://jenkins-refarch15d.eis-platformlive.cloud to https://jenkins-refarch15e.eis-platformlive.cloud
  - Remove the `jenkins-refarch15d` label from your repo
  - Confirm job was removed from https://jenkins-refarch15d.eis-platformlive.cloud
  - Add a new label `jenkins-refarch15e` to your repo
  - Confirm job was added from https://jenkins-refarch15e.eis-platformlive.cloud
  - **When switching labels, delete the old label and create a new label with 'jenkins-refarch15e'. Do not edit the existing label**
- The only library supported in `jenkins-refarch15e` is [Medusa]


#### New Secrets Retrieval Mechanism for using VAULT

- You no longer have to put config.hcl or template.ctmpl file in your repo.
- Application code no longer needs to place above files in config directory.
  - This is an automated step
- You now add a secrets-manifest.yaml to the /secrets/ directory in your repository. [Sample-Manifest](https://github.com/EBSCOIS/platform.infrastructure.vault-init/blob/master/configmap-mount/secrets_manifest.yaml)
  [Documentation](https://github.com/EBSCOIS/platform.infrastructure.vault-init#secret-manifest-to-consume-resources-in-a-pod-microservices)
- You no longer have to create multiple files to provision resources in Vault via platform.infrastructure.vault-resources. 
- To Provision Resources create a PR in to Resources Directory in [Vault-Init](https://github.com/EBSCOIS/platform.infrastructure.vault-init/tree/master/resources)
- [Sample-Provision-Manifest](https://github.com/EBSCOIS/platform.infrastructure.vault-init/blob/master/documentation-files/zSampleSecretsManifest.yaml)  

### NEW FEATURES

#### Gradle plugins and 5.2.1 upgrade

JSB repositories that use Medusa should make the following changes:

- Add two new plugins, `com.github.ben-manes.versions` and `com.pasam.gradle.buildinfo`, to `build.gradle` and update the versions of existing plugins.  The result should contain the following:
```gradle
plugins {
  // ...
  id 'com.github.ben-manes.versions' version '0.21.0'
  id 'com.pasam.gradle.buildinfo' version '0.1.3'
  id 'com.jfrog.artifactory' version '4.9.3'
  id 'org.owasp.dependencycheck' version '4.0.2'
  id 'org.sonarqube' version '2.7'
  id 'org.springframework.boot' version "2.1.3.RELEASE"
  id 'spring-cloud-contract' version "2.1.1.RELEASE"
}
```

- Update versions of the following dependencies in the `ext` section of `build.gradle`:
```gradle
ext {
  // ...
  // Compile dependency versions
  amazonAWSJavaSDKVersion = '1.11.519'
  lombokVersion = '1.18.6'
  springBootVersion = '2.1.3.RELEASE'
  springCloudContractVersion = '2.1.1.RELEASE'
  swaggerVersion = '2.9.2'

  // Test dependency versions
  junitJupiterVersion = '5.4.1'
  junitLauncherVersion = '1.4.1'
  mockitoVersion = '2.23.4'
}
```

- Update the Jacoco tool version in `build.gradle`:
```gradle
jacoco {
  toolVersion = '0.8.3'
}
```

- Add the following test runtime for `junit-platform-commons` to the `dependencies` section of `build.gradle`:
```gradle
dependencies {
  // Tests
  // ...
  testRuntime group: 'org.junit.platform', name: 'junit-platform-commons', version: "${junitLauncherVersion}"
```

- Add `mavenLocal()` to `settings.gradle`:
```gradle
pluginManagement {
  repositories {
    mavenLocal()
    // ...
```

- Run the following command to upgrade gradle wrapper to version 5.2.1:
  - `./gradlew wrapper --gradle-version 5.2.1 --distribution-type all`
- Stage and commit all the changes that includes the following files:
  - `gradle/wrapper/gradle-wrapper.jar`
  - `gradle/wrapper/gradle-wrapper.properties`
  - `gradlew`
  - `gradlew.bat`
  - `build.gradle`
  - `settings.gradle`


#### Put secrets in SSM Parameter Store using vault UI

* Select users can use VaultUI to put secrets in the AWS SSM Parameter store.
* [Using Vault UI to put secrets into AWS SSM Parameter Store](https://github.com/EBSCOIS/platform.infrastructure.vault-ssm/blob/master/README.md#using-vault-ui-to-put-secrets-in-aws-ssm-parameter-store)

<!--- Reused Links --->
[Medusa]: https://github.com/EBSCOIS/platform.infrastructure.medusa

 #### Baseline Alerts

 See [Alerting](./Alerting.md) guide

### BUG FIXES

#### NPM audit

An intermittent failure had been observed in Jenkins during audit, breaking builds. Thanks to :star: [@elliotmrodriguez](https://github.com/elliotmrodriguez) :star:, the NPM audit helper now has a retry mechanism and improved error messaging.


