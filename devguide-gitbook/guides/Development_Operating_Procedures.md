# SDLC for Reference Architecture 1.5

- [Overview](./Development_Operating_Procedures.md#Overview)
- [Introduction](./Development_Operating_Procedures.md#Introduction)
- [Logical SDLC Workflow](./Development_Operating_Procedures.md#LogicalSDLCWorkflow)
- [Dev-Centric Culture](./Development_Operating_Procedures.md#Dev-CentricCulture)
- [Definitions](./Development_Operating_Procedures.md#Definitions)
- [GitHub Flow Branching Strategy](./Development_Operating_Procedures.md#GitHubFlowBranchingStrategy)
- [Reference Branching Model](./Development_Operating_Procedures.md#ReferenceBranchingModel)
- [SDLC Assertions](./Development_Operating_Procedures.md#SDLCAssertions)
- [Pipeline Quality Gates](./Development_Operating_Procedures.md#PipelineQualityGates)
- [Reference Architecture 1.5 Pipelines](./Development_Operating_Procedures.md#ReferenceArchitecture1.5Pipelines)
- [Versioning](./Development_Operating_Procedures.md#Versioning)
- [Feature Toggles](./Development_Operating_Procedures.md#FeatureToggles)
- [References](./Development_Operating_Procedures.md#References)

# Overview

This page defines the Reference Architecture 1.5 SDLC to be used by teams in the delivery of business value differentiating functionality via the Hydra-based pipelines. This is a living document, which will be continuously updated as information becomes available based on team experiences and input from technology, business, and PPMO organizations.

# Introduction

This document defines the Software Development Life-cycle (SDLC) for the 1.5 Reference Architecture.  The SDLC is the workflow a developer uses to deliver business value into Live environments.  It defines the developer workflow, branching strategy, and best practices to be used when developing and releasing applications and services into our private and public cloud environments through the Hydra/Medusa based pipelines.  The Reference Architecture 1.5 SDLC and branching strategy is informed by the AWS/Microservices Reference Architecture 1.0 and the On-Prem Reference Architecture.

**AWS/Microservice Reference Architecture SDLC:**

- [SDLC for Reference Architecture](http://confluence/display/entarch/SDLC+for+Reference+Architecture)
- [PLATFORM-207: Github Flow](http://confluence/display/entarch/PLATFORM-207%3A+Github+Flow)

**On-Prem Reference Architecture SDLC:**

- [SDLC for On-Prem Reference Architecture](http://confluence/display/ART/SDLC+for+On-Prem+Reference+Architecture)

# Logical SDLC Workflow <a id=LogicalSDLCWorkflow></a>

A complex workflow blocks developer productivity.  The following workflow, enforced through the use of the Medusa and Hydra pipeline libraries, creates a simple yet powerful workflow that enables:

- Faster delivery of business value into Live environments
- Enforcement of key NFRs, without any developer effort
- Complete consistency across all environments
- Dedicated Preview environment for acceptance testing prior to merge

![](../images/SDLC_1.5.png)

# Dev-Centric Culture <a id=Dev-CentricCulture></a>

See: [http://confluence/display/entarch/Reference+Architecture#ReferenceArchitecture-DevCentricculture](http://confluence/display/entarch/Reference+Architecture#ReferenceArchitecture-DevCentricculture)

#### Extensive Collaboration and Shared Responsibility

- Partnership with Site Reliability Team, NOC, LiveOps in Monitoring Live
- Team owns ensuring Live viability for all changes promoted to Master

#### No Silos

- Co-Ownership with SRE, LiveOps of:  Live monitoring of errors rates/dashboards, alerts, performance telemetry dashboards
- Quality is a concern of development (built-in quality)

#### Autonomous Teams

- Team owns creation of Pull Requests into Master.
- Team owns PR approvals and acts as Continuous Operations owner. In certain cases SA/Program Team level approval may be needed.

#### High Quality Development Process

- Team ensures all quality-first practices are followed
- CI processes provide fast feedback to teams
- CD processes enforce testing gates
- Teams leverage Preview environment for acceptance
- Teams build resiliency into systems
  - circuit breakers
  - zero downtime deployments

#### Valuing Feedback

- Teams look to measure everything and drive continuous improvement from metrics
- Teams value and respond quickly to defects reported from SRE, LiveOps and CustSat

#### Automation

- Teams build pipelines to Live following the Reference Architecture 1.5
- See:  [https://github.com/EBSCOIS/platform.training.refarch1.5-devguide](https://github.com/EBSCOIS/platform.training.refarch1.5-devguide)

# Definitions

- **Master** - EBSCOIS base repository. This repository is the starting point for all branches. All builds and deployments are sourced from this repository. Only the builds should have access to master. Only user story branches should be created here. Tags should be long-lived snapshots of the code.
- **User Story Branch Origin** - Personal repository. Each developer has their own origin. Developers can grant access to their origin as desired. Master branch should never contain local changes/work. User Story Branch Origins should always be kept in sync with the Master.
- **User Story Branch Local** - Local repository on the developers machine.
- **Developer Remotes** - Additional remotes added to collaboratively work with developers without triggering a build

# GitHub Flow Branching Strategy <a id=GitHubFlowBranchingStrategy></a>

The Branching Strategy for the Reference Architecture 1.5 follows the simplified GitHub Flow model that uses a &quot;Branch and Merge&quot; process:

[https://help.github.com/articles/github-flow/](https://help.github.com/articles/github-flow/)

# Reference Branching Model <a id=ReferenceBranchingModel></a>

![](../images/RefArch1.5BranchingModel.png)

| # | Step | Description |
| :---: | --- | --- |
| 1 | Create feature/some-name Branch | Clone Master and create a tagged branch.  Dev work scaled to two-week development and release. |
| 2 | Commit Changes | Make changes to local, run tests locally, then push to Branch Origin.  Commits will trigger the deploy CI process triggers unit test run. |
| 3 | Create PR | The build system will automate the pull from master but merge conflicts will need to be resolved manually. |
| 4 | CI Pipeline publishes versioned artifact | Artifact pushed into Artifactory. CI tests (unit tests, integration tests, CDC) run before artifacts are published.  |
| 5 | Preview Environment created | Used for feature/story acceptance testing and team demos.  The Preview environment is automatically generated by creating a pull request.  Preview environment should not be used for Performance tests.  Preview environments are automatically cleaned up after a set time to live. A push can be used to recreate the Preview environment again if necessary.   |
| 6 | Master Merge | PR approval required. |
| 7 | CD Pipeline Release into Staging Env | Follows Canary deployment pattern. Automated release verification performed. Automatic promotion if gate passes.  Staging environment mirrors the Live enviroment and is suitable for running performance tests. |
| 8 | CD Pipeline Release into Live Env(s) | Follows Canary deployment pattern. Automated release verification performed. |
| 9 | Enable Live traffic | Automated promotion once all gates are passed. This step includes canary testing which is automated by [Hydra](https://github.com/EBSCOIS/platform.infrastructure.hydra#deployment-manifest) and can happen from 1 to n times. This stage can also be used for dark traffic testing.  |
| 10 | Review and Verify | Operations confirmed with live traffic. Validate Performance and Behavior. |

# SDLC Assertions <a id=SDLCAssertions></a>

- All User Story Branches are created from Master
  - Do update (Pull down from Master) into your User Story branches frequently (At least daily)
  - Do merge to Master regularly (At least weekly)
- Master is kept in a releasable state at all times
  - The Master represents a collection of Live versions and intended releases
  - Do Not commit into Master directly
  - Do apply Hotfixes using a User Story Branch
  - Do Not rebase Master
- A Branch commit triggers a CI build
  - no versioned artifact created
  - unit tests are run
- A Pull Request triggers the creation of a Preview env
  - Quality gates must pass in this env
  - Team level Acceptance testing is done in this env
  - Do push user story branches for discussion prior to issuing a PR
  - PRs should represent small code changes that can be reviewed quickly
  - Do Not introduce breaking changes (follow SOLID, 12-factor)
- A Pull Request Approval triggers the merge into Master
  - PO/PM/SA acceptance drives PR approval
- A merge into Master triggers the CD process
  - Do Not merge in broken code
  - Do Not merge with conflicts (handle conflicts upon rebasing)
  - Do Tag all releases

# Pipeline Quality Gates <a id=PipelineQualityGates></a>

Each delivery into an environment (Preview, Staging, Live) follows the Canary promotion methodology.  All promotion events must be gated by the successful completion of a Quality Gate consisting of a set of tests appropriate for the environment.  This helps to ensure that the version of the service being promoted into use within a given environment is fit-for-purpose.

## Test Gates

For guidance on testing, including Consumer-Driven Contract testing and Performance testing, see:  [https://github.com/EBSCOIS/platform.training.refarch1.5-devguide/blob/master/guides/Quality_Gates_Medusa.md](https://github.com/EBSCOIS/platform.training.refarch1.5-devguide/blob/master/guides/Quality_Gates_Medusa.md)

## Stage Gates

### Branch Builds

CI process initiated by a commit into a non-Master branch. Unit test gate is triggered.

### Preview

Initiated by a commit in a feature branch or pull request. Preview environments last for a define set of time by default; please refer to [Hydra](https://github.com/EBSCOIS/platform.infrastructure.hydra) document for time to live information.  CI tests run. End-to-End tests are optional.  Preview environment is constructed in the Staging cluster but in a cost-optimized way and should not be used for performance test.  Components deployed to the Preview environment will work with other components already deployed in the Staging environment by default. However, the preview environment can also deploy additional components besides your own via an YAML configuration to provide an isolated environment to conduct testing and minimize interference to other teams.

Acceptance testing at the team level is done in this environment.  PRs should not be approved until sufficient testing has been completed for the PO/PM/SA to accept the feature or user story.

### Staging

CI process initiated by a merge to Master.  The Staging environment is the next higher environment pipelines deliver into and mirrors the Live environment.  It is the environment where full CD tests (E2E and Performance tests) can be executed.  

### Live

The Live environments are the final environments that the pipelines deliver into.  The Live environments are where we need to ensure the newly deployed version is operationally viable.  In this case it is acceptable to run a smaller set of &quot;Smoke Tests&quot; and CD tests to ensure that the newly deployed version operates as expected based on the major use cases supported by the component.

# Versioning

[Semantic Versioning](http://semver.org/) should be used by all services being delivered into an environment.

Given a version number MAJOR.MINOR.PATCH, increment the:

1. MAJOR version when you make incompatible API changes,
2. MINOR version when you add functionality in a backwards-compatible manner, and
3. PATCH version when you make backwards-compatible bug fixes.

# Feature Toggles <a id=FeatureToggles></a>

### Note:  Support for Feature Toggles in 1.5 will not be in place until after PI12.

[Feature Toggles](https://martinfowler.com/articles/feature-toggles.html) **may be used to:**

- isolate work in progress
- provide a mechanism to dynamically enable new business functionality post release
- enable canary testing of experimental algorithms
- enable A/B testing

**Feature Toggle Best Practices:**

- Feature Toggles must have a defined expiration date.
- Treat Feature Toggles as Technical Debt.  Code supporting the feature toggle must be removed once the defined expiration date has been met.
- Testing must cover all Feature Toggle permutations - USE THEM SPARINGLY.

# References

### Reference Architecture Test Standards

- [Microservices Test Strategy](http://confluence/display/~abhavan/Microservices+Test+Strategy)
- [SERVICES-260: Pipeline Testing](http://confluence/display/entarch/SERVICES-260%3A+Pipeline+Testing)
- [UI-260: DevTest - Automated E2E testing](http://confluence/display/entarch/UI-260%3A+DevTest+-+Automated+E2E+testing)
- [SERVICES-270: Microservices Testing](http://confluence/display/entarch/SERVICES-270%3A++Microservices+Testing)
- [SERVICES-280: Testing Overview](http://confluence/display/entarch/SERVICES-280%3A+Testing+Overview)

### Sonarqube Quality Profiles:

[http://sonarqube73.eis-platformlive.cloud/profiles](http://sonarqube73.eis-platformlive.cloud/profiles)

### Reference Architecture 1.5 Feedback Channel

[Links to Teams Channel](https://teams.microsoft.com/l/team/19%3afa2ca3ef3b8042438565ebe7c5e71731%40thread.skype/conversations?groupId=9b1ce806-0126-471c-8e35-77b3115110e6&amp;tenantId=50fa36ca-7dd3-44f1-9e3f-1bf39a3963a5)
