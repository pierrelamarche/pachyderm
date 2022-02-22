# Upgrade Pachyderm

Upgrades between minor releases or point releases, such as from version `2.0.0` to
version `2.0.1` do not introduce breaking changes. Therefore, the upgrade
procedure is simple and requires little to no downtime.

!!! Warning
    Do not use these steps to upgrade between major versions because
    it might result in data corruption.

To upgrade Pachyderm from one minor release to another, complete the following steps:

1. Back up your cluster as described in the [Backup and Restore](../backup_restore/#backup-your-cluster)
section.

1. **Make sure your helm values file is up to date**.

      Some values are automatically generated during install. **If you don't include these back into your values file when you upgrade, the upgrade will fail**.

      The settings that are autogenerated if they're blank during install are:

      ```yaml 
      global:
            postgresql.postgresqlPassword
      pachd:
            clusterDeploymentID
            rootToken
            enterpriseSecret
            oauthClientSecret
      ```

      **You must add them to your values file** or supply them via `--set` on the command line during the upgrade.

1. Upgrade `pachctl` by using `brew` for macOS or `apt` for Linux:

      **Example:**

      ```shell
      brew upgrade pachyderm/tap/pachctl@{{ config.pach_major_minor_version }}
      ```

      **System response:**

      ```shell
      ==> Upgrading 1 outdated package:
      pachyderm/tap/pachctl@{{ config.pach_major_minor_version }}
      ==> Upgrading pachyderm/tap/pachctl@{{ config.pach_major_minor_version }}
      ...
      ```

      **Note:** You need to specify the major/minor version of `pachctl` to which
      you want to upgrade. For example, if you want to upgrade `2.0.0` to
      the latest point release of the 1.12, add `@2.0` at the end of the upgrade path.

2. Confirm that the new version has been successfully installed by running
the following command:

      ```shell
      pachctl version --client-only
      ```

      **System response:**

      ```shell
      COMPONENT           VERSION
      pachctl             {{ config.pach_latest_version }}
      ```

1. Redeploy Pachyderm by running the [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/){target=_blank} command
with the same values file that you specified when you deployed the previous version
of Pachyderm:

      ```shell
      helm upgrade pachd -f my_pachyderm_values.yaml pach/pachyderm
      ```

      **System response:**

      ```shell
      Release "pachd" has been upgraded. Happy Helming!
      NAME: pachd
      LAST DEPLOYED: Wed Sep 22 13:37:45 2021
      NAMESPACE: default
      STATUS: deployed
      REVISION: 2
      ```

      The upgrade can take some time. You can run `kubectl get pods` periodically
      to check the status of the deployment. When Pachyderm is deployed, the command
      shows all pods as `READY`:


      ```shell
      kubectl get pods
      ```
      Once the pods are up, you should see a pod for `pachd` running 
      (alongside etcd, pg-bouncer or postgres, console, depending on your installation). 

      **System response:**

      ```shell
      NAME                     READY     STATUS    RESTARTS   AGE
      pachd-3677268306-9sqm0   1/1       Running   0          4m
      ...
      ```

1. Verify that the new version has been deployed:

      ```shell
      pachctl version
      ```

      **System response:**

      ```shell
      COMPONENT           VERSION
      pachctl             {{ config.pach_latest_version }}
      pachd               {{ config.pach_latest_version }}
      ```

      The `pachd` and `pachctl` versions must both match the new version.

## Troubleshooting point release Upgrades

This section describes issues that you might run into when
upgrading Pachyderm and provides guidelines on how to resolve
them.

### `etcd` re-deploy problems

Depending on the cloud you are deploying to and the previous deployment configuration, 
we have seen certain cases in which volumes don't get attached to the right nodes on re-deploy (especially when using AWS). 

In these scenarios, you may see the `etcd` pod stuck in a `Pending`, `CrashLoopBackoff`, or other failed state. 
Most often, deleting the corresponding `etcd` pod(s) or nodes to redeploy them 
or re-deploying all of Pachyderm again will fix the issue. 
