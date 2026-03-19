#!/bin/bash
# This script is provided by by Michael Willer at enterprisedb.com. 
# It is provided "as-is" and without warranties of any kind either expressed or implied.

PLUGIN_NAME=cnpg # Open source CloudNativePg uses 'cnpg', EDB subscribed operator uses 'cnp'.

# REQUIREMENTS:
# - The ${PLUGIN_NAME} kubectl plugin must be installed and available as `kubectl ${PLUGIN_NAME}`.
# - jq must be installed for JSON parsing.
# - You must have access to all relevant namespaces.


OUTPUT_FILE=/dev/stdout #"${PLUGIN_NAME}_clusters_cpu_limits.csv"
echo "Cluster,Namespace,Total_CPU_Limit" > "$OUTPUT_FILE"

# List all CNPG clusters with their namespaces
clusters=$(kubectl get clusters -A -o json | jq -r '.items[] | [.metadata.name, .metadata.namespace] | @tsv')
sum_cpu=0

while IFS=$'\t' read -r cluster ns; do
    # Find all pods in the namespace belonging to this cluster
    pods=$(kubectl get pods -n "$ns" -l "cnpg.io/cluster=$cluster" -o jsonpath='{.items[*].metadata.name}')
    total_cpu=0

    for pod in $pods; do
        # Sum CPU limits for all containers in the pod
        pod_cpu=$(kubectl get pod "$pod" -n "$ns" -o json | \
            jq '[.spec.containers[].resources.limits.cpu // "0"] | map(
                if test("m$") then (. | sub("m$";"") | tonumber / 1000) else (. | tonumber) end
            ) | add')
        # Add to cluster total (handle nulls)
        pod_cpu=${pod_cpu:-0}
        total_cpu=$(awk "BEGIN {print $total_cpu + $pod_cpu}")
    done
    sum_cpu=$(awk "BEGIN {print $sum_cpu + $total_cpu}")

    if [ "$total_cpu" = "0" ]; then
			echo "$cluster,$ns,$total_cpu,ERROR-NO-RESOURCE-LIMITS" >> "$OUTPUT_FILE"
		else
			echo "$cluster,$ns,$total_cpu" >> "$OUTPUT_FILE"
		fi

done <<< "$clusters"

echo "Sum of CPUs: $sum_cpu"
echo "Export complete. Results saved to $OUTPUT_FILE"
