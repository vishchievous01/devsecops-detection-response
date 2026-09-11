# DevSecOps Detection & Response

A security-focused DevSecOps laboratory that integrates **application
security, infrastructure security, Kubernetes hardening, policy
enforcement, and runtime threat detection** into a CI/CD-oriented
workflow.

The project demonstrates how security controls can be implemented across
the software delivery lifecycle rather than relying only on
post-deployment monitoring.

## Project Overview

The repository brings together multiple security layers:

-   **Application security** --- static analysis and security findings
    with Semgrep.
-   **Infrastructure security** --- Terraform security controls and
    hardened cloud storage configuration.
-   **Container/Kubernetes security** --- Kubernetes hardening and
    policy enforcement.
-   **Policy as Code** --- Kyverno policies for enforcing Kubernetes
    security requirements.
-   **Runtime detection** --- Falco-based detection of suspicious
    container/Kubernetes activity.
-   **Security automation** --- GitHub Actions workflows that integrate
    security checks into the development pipeline.

### Security Architecture

``` text
Developer
   |
   v
Git Repository
   |
   v
GitHub Actions
   |
   +--------------------+
   |                    |
   v                    v
Application SAST     Infrastructure
(Semgrep)            Security
   |                    |
   |                    v
   |                 Terraform
   |                    |
   +---------+----------+
             |
             v
      Kubernetes Security
             |
      +------+------+
      |             |
      v             v
   Kyverno         Hardening
 Policy Engine     Controls
      |
      v
 Kubernetes Workloads
      |
      v
 Runtime Monitoring
      |
      v
     Falco
      |
      v
 Detection / Response
```

## Repository Structure

``` text
devsecops-detection-response/
├── .github/
│   └── workflows/       # CI/CD security automation
├── app/                  # Application source and security configuration
├── k8s/                  # Kubernetes manifests and hardening configuration
├── kyverno/              # Kyverno security policies
├── terraform/            # Infrastructure as Code and security controls
├── falco-wazuh-bridge/   # Falco → Wazuh event forwarding bridge
├── .gitignore
├── .gitkraken.toml
└── falco-values.yaml     # Falco deployment/configuration values
```

## Security Controls

#### 1. Application Security

The `app/` component is used to demonstrate application-level security
scanning.

**Semgrep** is integrated to identify potentially insecure code patterns
and security findings before deployment.

Typical workflow:

``` text
Source Code
    |
    v
Semgrep Scan
    |
    v
Security Findings
    |
    v
CI/CD Decision
```

This demonstrates the **Shift Left** security principle by identifying
vulnerabilities during development.

#### 2. Infrastructure Security

The `terraform/` directory contains Infrastructure as Code with
security-focused controls.

The project demonstrates how cloud infrastructure can be hardened
through Terraform instead of relying on manual configuration.

Security objectives include:

-   Restricting unnecessary public access.
-   Applying secure storage configuration.
-   Enforcing infrastructure security controls as code.
-   Making infrastructure changes reviewable through Git.

#### 3. Kubernetes Security

The `k8s/` directory contains Kubernetes configuration used for
deploying and hardening workloads.

Security considerations include:

-   Reducing unnecessary privileges.
-   Applying safer workload configurations.
-   Enforcing Kubernetes security requirements.
-   Integrating policy validation into the deployment lifecycle.

#### 4. Kyverno Policy Enforcement

The `kyverno/` directory contains **Kyverno Policy as Code**
configuration.

Kyverno can be used to validate, mutate, and enforce Kubernetes security
policies.

Example security objectives:

``` text
Kubernetes Resource
       |
       v
Kyverno Policy
       |
   +---+---+
   |       |
 Pass     Fail
   |       |
   v       v
Deploy    Reject
```

This creates an additional preventive control before insecure workloads
are allowed into the cluster.

#### 5. Runtime Threat Detection

The project uses **Falco** for runtime security monitoring.

Falco observes system and container activity and can detect suspicious
behavior after workloads are deployed.

Examples of runtime events that can be monitored include:

-   Unexpected process execution.
-   Suspicious command execution inside containers.
-   Abnormal file activity.
-   Privilege-related activity.
-   Unexpected access to sensitive resources.

This complements static and preventive controls with **runtime
detection**.

#### 6. Falco → Wazuh Event Integration

The `falco-wazuh-bridge/` component connects Falco runtime detections with Wazuh.

The event flow is:

```text
Falco
   |
   v
Falcosidekick
   |
   v
Falco-Wazuh Bridge
   |
   v
JSON Event Log
   |
   v
Wazuh Logcollector
   |
   v
Wazuh Detection Pipeline
```

The bridge receives Falco events over HTTP, serializes them as JSON lines, and writes them to a log file consumed by Wazuh.

This demonstrates integration between runtime container detection and centralized security monitoring.


## DevSecOps Security Pipeline

The overall security model follows multiple layers:

``` text
        PRE-COMMIT / CI
              |
              v
        Semgrep / SAST
              |
              v
       Infrastructure Scan
              |
              v
      Kubernetes Validation
              |
              v
       Kyverno Policies
              |
              v
          Deployment
              |
              v
       Runtime Monitoring
              |
              v
            Falco
              |
              v
     Detection & Response
```

The goal is to combine:

**Prevent → Detect → Respond**

rather than treating security as a single scanning step.

## Technologies

  Area                      Technology
  ------------------------- ----------------
  CI/CD                     GitHub Actions
  SAST                      Semgrep
  Infrastructure as Code    Terraform
  Container Orchestration   Kubernetes
  Kubernetes Policy         Kyverno
  Runtime Security          Falco
  Application               Python
  Configuration             HCL / YAML
  Containerization          Docker

## Project Goals

This project is intended to demonstrate practical understanding of:

-   DevSecOps
-   Shift-left security
-   Security automation
-   SAST
-   Infrastructure as Code security
-   Kubernetes security
-   Policy as Code
-   Container security
-   Runtime threat detection
-   CI/CD security gates
-   Detection and response concepts

## How to Use

### 1. Clone the Repository

``` bash
git clone https://github.com/vishchievous01/devsecops-detection-response.git
cd devsecops-detection-response
```

### 2. Review the Security Pipeline

The repository is designed to be used as a security pipeline rather than
as a single standalone executable.

Start by reviewing:

``` text
.github/workflows/
app/
terraform/
k8s/
kyverno/
falco-values.yaml
```

The GitHub Actions workflows automate security checks when changes are
pushed to the repository or when the configured workflow events occur.

### 3. Run Application Security Scanning

If Semgrep is installed locally, scan the application directory:

``` bash
semgrep scan --config auto app/
```

For CI/CD usage, the corresponding workflow under `.github/workflows/`
can perform the security scan automatically.

Review the findings before allowing the application to proceed through
the pipeline.

### 4. Validate Terraform

Move into the Terraform configuration:

``` bash
cd terraform
```

Initialize Terraform:

``` bash
terraform init
```

Validate the configuration:

``` bash
terraform validate
```

Review the proposed infrastructure changes:

``` bash
terraform plan
```

Do not apply infrastructure changes to a real environment unless the
configuration has been reviewed and you have authorization to modify
that environment.

### 5. Deploy the Kubernetes Components

Review the manifests before deployment:

``` bash
cd ../k8s
```

Validate the manifests with your Kubernetes tooling:

``` bash
kubectl apply --dry-run=client -f .
```

If the cluster is an authorized test environment, deploy the manifests:

``` bash
kubectl apply -f .
```

Check the resulting workloads:

``` bash
kubectl get pods -A
kubectl get deployments -A
kubectl get services -A
```

### 6. Apply Kyverno Policies

The policies in `kyverno/` are intended to enforce Kubernetes security
requirements.

Review the policies first:

``` bash
cd ../kyverno
ls
```

With Kyverno installed in the target cluster, apply the required
policies:

``` bash
kubectl apply -f .
```

Verify that the policies are present:

``` bash
kubectl get clusterpolicies
kubectl get policies -A
```

A workload that violates an enforced policy may be reported or rejected
depending on the policy configuration.

### 7. Deploy Falco for Runtime Detection

The `falco-values.yaml` file contains configuration values for the Falco
deployment.

If Helm and Falco are configured in your authorized Kubernetes lab,
install or upgrade Falco using the repository's values file:

``` bash
helm upgrade --install falco falcosecurity/falco \
  -f falco-values.yaml
```

Then verify the deployment:

``` bash
kubectl get pods -A | grep falco
```

Inspect Falco events/logs:

``` bash
kubectl logs -l app.kubernetes.io/name=falco -n falco
```

The exact namespace/labels can vary with the Helm chart version, so use
`kubectl get pods -A` if the final command does not match your
deployment.

### 8. Test the Detection Pipeline

A basic test flow is:

``` text
1. Make a controlled code change
          ↓
2. GitHub Actions runs security checks
          ↓
3. Semgrep identifies application findings
          ↓
4. Terraform/Kubernetes configuration is validated
          ↓
5. Kyverno evaluates Kubernetes resources
          ↓
6. Approved workloads are deployed
          ↓
7. Falco monitors runtime activity
          ↓
8. Suspicious activity generates a detection
```

For runtime testing, use only controlled activity inside your own lab
cluster. Do not test against systems or workloads without authorization.

### 9. Recommended Development Workflow

For normal development:

``` bash
git checkout -b security-change
```

Make the required change, then validate it locally:

``` bash
semgrep scan --config auto app/

cd terraform
terraform validate

cd ../k8s
kubectl apply --dry-run=client -f .

cd ../kyverno
kubectl apply --dry-run=client -f .
```

Commit and push the change:

``` bash
git add .
git commit -m "test: update security configuration"
git push origin security-change
```

The configured GitHub Actions workflows can then perform the automated
security checks.

## Operational Flow

The intended usage can be summarized as:

``` text
                 Git Push
                    |
                    v
          +-------------------+
          | GitHub Actions    |
          +-------------------+
             |      |      |
             v      v      v
          Semgrep Terraform K8s
             |      |      |
             +------+------+
                    |
                    v
             Security Gates
                    |
                    v
              Kubernetes
                    |
                    v
                Kyverno
                    |
                    v
              Application
                    |
                    v
                  Falco
                    |
                    v
          Runtime Detection
```

This makes the repository useful as a **portfolio demonstration of an
end-to-end DevSecOps security lifecycle**: security testing before
deployment, policy enforcement during deployment, and runtime detection
after deployment.

## Security Model

The project can be viewed as a layered defense architecture:

``` text
Layer 1 ─ Application Security
          └── Semgrep

Layer 2 ─ Infrastructure Security
          └── Terraform controls

Layer 3 ─ Kubernetes Security
          └── Hardening

Layer 4 ─ Policy Enforcement
          └── Kyverno

Layer 5 ─ Runtime Detection
          └── Falco

Layer 6 ─ Response
          └── CI/CD and operational response workflows
```

Each layer addresses a different point in the attack lifecycle.

## Why This Project Matters

A traditional pipeline may focus primarily on whether an application
builds successfully.

A DevSecOps pipeline additionally asks:

> Is the code secure?
>
> Is the infrastructure secure?
>
> Are Kubernetes workloads configured securely?
>
> Are security policies being enforced?
>
> Can suspicious runtime behavior be detected?

This repository demonstrates that security controls can be integrated
throughout the software lifecycle.

## Disclaimer

This project is intended for **educational, defensive security, and
authorized testing purposes**.

Only deploy security testing and detection scenarios against systems and
environments that you own or have explicit permission to test.
