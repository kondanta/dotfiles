if not command -q kubie
    echo "Install kubie for kubectl context and kubectl namespace operations"
end

if not command -q kubectl
    echo "Install kubectl first"
end

abbr k 'kubectl'

# Core shortcuts from gen_kuberc
alias ksys='kubectl --namespace=kube-system'
alias ka='kubectl apply --recursive -f'
alias kak='kubectl apply -k'
alias kex='kubectl exec -i -t'
alias klo='kubectl logs -f'
alias klop='kubectl logs -f -p'
alias kp='kubectl proxy'
alias kpf='kubectl port-forward'
alias kg='kubectl get'
alias kd='kubectl describe'
alias krm='kubectl delete'
alias krun='kubectl run --rm --restart=Never --image-pull-policy=IfNotPresent -i -t'
alias kgpo='kubectl get pods'
alias kdpo='kubectl describe pods'
alias krmpo='kubectl delete pods'
alias kgdep='kubectl get deployment'
alias kddep='kubectl describe deployment'
alias krmdep='kubectl delete deployment'
alias kgsts='kubectl get statefulset'
alias kdsts='kubectl describe statefulset'
alias krmsts='kubectl delete statefulset'
alias kgds='kubectl get daemonset'
alias kdds='kubectl describe daemonset'
alias kgsvc='kubectl get service'
alias kdsvc='kubectl describe service'
alias krmsvc='kubectl delete service'
alias kging='kubectl get ingress'
alias kding='kubectl describe ingress'
alias krming='kubectl delete ingress'
alias kgcm='kubectl get configmap'
alias kdcm='kubectl describe configmap'
alias krmcm='kubectl delete configmap'
alias kgsec='kubectl get secret'
alias kdsec='kubectl describe secret'
alias krmsec='kubectl delete secret'
alias kgno='kubectl get nodes'
alias kdno='kubectl describe nodes'
alias kgns='kubectl get namespaces'
alias kdns='kubectl describe namespaces'
alias kgpdb='kubectl get poddisruptionbudget'
alias kdpdb='kubectl describe poddisruptionbudget'
alias kgoyaml='kubectl get -o=yaml'
alias kgowide='kubectl get -o=wide'
alias kgojson='kubectl get -o=json'
alias kgall='kubectl get --all-namespaces'
alias kgpoall='kubectl get pods --all-namespaces'
alias kgdepall='kubectl get deployment --all-namespaces'
alias kgsvcall='kubectl get service --all-namespaces'
alias kgw='kubectl get --watch'
alias kgpow='kubectl get pods --watch'
alias kgdepw='kubectl get deployment --watch'
alias kgsvcw='kubectl get service --watch'
alias kgpoowide='kubectl get pods -o=wide'
alias kgdepowide='kubectl get deployment -o=wide'
alias kgsvcowide='kubectl get service -o=wide'

function ctx
    if test "$argv[1]" = "-f"
        kubie ctx --kubeconfig "$argv[2]"
    else if test (count $argv) -gt 0
        kubie ctx $argv[1]
    else
        kubie ctx
    end
end

function ns
    if test (count $argv) -gt 0
        kubie ns $argv[1]
    else
        kubie ns
    end
end

function kctx
    kubectl config current-context
end

function klsctx
    kubectl config get-contexts
end

function ksetctx
    kubectl config use-context $argv[1]
end

function kns
    kubectl config view --minify -o jsonpath='{..namespace}'
    echo
end

function kgv
    kubectl lineage $argv[1] --output=split --show-group
end

function kgew
    if test "$argv[1]" = "-A"
        kubectl get events -A -w --field-selector=type=Warning --sort-by='.metadata.creationTimestamp'
    else
        kubectl get events -w --field-selector=type=Warning --sort-by='.metadata.creationTimestamp'
    end
end

function kgee
    if test "$argv[1]" = "-A"
        kubectl get events -A -w --field-selector=type=Error --sort-by='.metadata.creationTimestamp'
    else
        kubectl get events -w --field-selector=type=Error --sort-by='.metadata.creationTimestamp'
    end
end

function kgewf
    if test "$argv[1]" = "-h"
        echo "### CertificateSigningRequest ###"
        echo "spec.signerName"
        echo ""
        echo "### Event ###"
        echo "involvedObject.kind, involvedObject.namespace, involvedObject.name"
        echo "reason, type, reportingComponent"
        echo ""
        echo "### Pod ###"
        echo "spec.nodeName, spec.restartPolicy, spec.serviceAccountName"
        echo "status.phase, status.podIP"
        echo ""
        echo "### Node ###"
        echo "spec.unschedulable"
        return 0
    end
    if test "$argv[2]" = "-A"
        kubectl get events -w -A --field-selector=$argv[1] --sort-by='.metadata.creationTimestamp'
    else
        kubectl get events -w --field-selector=$argv[1] --sort-by='.metadata.creationTimestamp'
    end
end

function cani
    kubectl auth can-i --list
end

function succeeded
    kubectl get pod -o=jsonpath='{.items[?(@.status.phase=="Succeeded")].metadata.name}'
end

function rusage
    if test (count $argv) -lt 1
        echo "Provide label selector"
        return 1
    end
    set filter
    if test (count $argv) -lt 2
        set filter (echo $argv[1] | cut -d'=' -f2)
    else
        set filter $argv[2]
    end
    kubectl resource_capacity -c -l=$argv[1] -u | begin
        read -l header
        echo $header
        rg $filter
    end
end

function kallresources
    kubectl api-resources --verbs=list -o name --namespaced | xargs -n 1 kubectl get --show-kind --ignore-not-found
end

function kgs
    if test (count $argv) -lt 2
        kubectl get secret "$argv[1]" -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
    else
        kubectl get secret -n $argv[2] "$argv[1]" -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
    end
end
