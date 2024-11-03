Here are some handy `kubectl` aliases to streamline Kubernetes workflows. These can make common tasks quicker and reduce the need to remember lengthy commands. You can add these aliases to your `.bashrc` file for convenience.

### Common Aliases

1. **List all pods in all namespaces (wide view)**
   ```bash
   alias kga='kubectl get pods -o wide -A'
   ```

2. **Get all resources in the current namespace**
   ```bash
   alias kgall='kubectl get all'
   ```

3. **Quick describe pod**
   ```bash
   alias kdp='kubectl describe pod'
   ```

4. **Delete a pod quickly**
   ```bash
   alias kdelp='kubectl delete pod'
   ```

5. **View logs for a pod**
   ```bash
   alias kl='kubectl logs'
   ```

6. **View logs for a pod with continuous output**
   ```bash
   alias klf='kubectl logs -f'
   ```

7. **View logs of all containers in a pod**
   ```bash
   alias klfa='kubectl logs -f --all-containers'
   ```

8. **Run a quick command in a pod (for troubleshooting)**
   ```bash
   alias kexec='kubectl exec -it'
   ```

9. **Apply a manifest file**
   ```bash
   alias kap='kubectl apply -f'
   ```

10. **Delete a resource from a manifest file**
    ```bash
    alias kdel='kubectl delete -f'
    ```

11. **Get current context**
    ```bash
    alias kc='kubectl config current-context'
    ```

12. **List all contexts**
    ```bash
    alias kctx='kubectl config get-contexts'
    ```

13. **Switch context**
    ```bash
    alias ksctx='kubectl config use-context'
    ```

14. **Get nodes with wide output**
    ```bash
    alias knodes='kubectl get nodes -o wide'
    ```

15. **Get persistent volume claims (PVCs) in all namespaces**
    ```bash
    alias kpvc='kubectl get pvc -A'
    ```

16. **Get services in the current namespace**
    ```bash
    alias ksvc='kubectl get svc'
    ```

17. **Quickly apply all YAML files in a directory**
    ```bash
    alias kapd='kubectl apply -f .'
    ```

### Advanced Aliases

1. **Get all pods not in "Running" state**
   ```bash
   alias knr='kubectl get pods --field-selector=status.phase!=Running'
   ```

2. **Restart all pods in a deployment (useful for refreshing)**:
   ```bash
   alias kres='kubectl rollout restart deployment'
   ```

3. **Port forward to a specific service (specify port)**:
   ```bash
   alias kpf='kubectl port-forward svc/'
   ```

4. **Get events in all namespaces (useful for troubleshooting)**
   ```bash
   alias kevents='kubectl get events -A --sort-by=.metadata.creationTimestamp'
   ```

5. **Get current namespace**
   ```bash
   alias kns='kubectl config view --minify --output "jsonpath={..namespace}"'
   ```

6. **View the resource usage (CPU/memory) of nodes**
   ```bash
   alias ktopn='kubectl top nodes'
   ```

7. **View the resource usage (CPU/memory) of pods**
   ```bash
   alias ktop='kubectl top pods'
   ```

8. **Tail logs of a specific container in a pod**
   ```bash
   alias klc='kubectl logs -f -c'
   ```
