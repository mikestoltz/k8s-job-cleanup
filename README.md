## Kubernetes Job Cleanup CronJob

CronJob to clean up kubernetes jobs by selector after they reach a certain age.

### Environment variable configurations:

`NAMESPACE` - namespace to clean up jobs in, will default to all namespaces

`SELECTORS` - label selector to select jobs to delete, will default to all job in namespace(s)

`CLEANUP_OFFSET` - offset into the past to skip over in seconds. Set to 86400 to leave jobs from the last day - set to 0 to clean up all job. Defaults to 86400.

`DRY_RUN` - if set to true, the job name will be printed instead of deleted


### Example Useage
``` yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: k8s-job-cleanup
  namespace: workers
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: mikestoltz/k8s-job-cleanup:latest
            env:
              - name: NAMESPACE
                value: "workers"
              - name: SELECTORS
                value: "app=my-worker"
          restartPolicy: OnFailure
```

### RBAC
If your cluster has rbac enabled, the default service account for the namespace the job will run in needs permission to list & delete jobs.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: k8s-job-cleanup-admin
  namespace: workers
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: workers
```