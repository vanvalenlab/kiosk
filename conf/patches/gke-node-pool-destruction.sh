echo "Destroying prediction GPU node pool..."
until gcloud container node-pools delete prediction-gpu --quiet --region ${GPU_COMPUTE_REGION}
do
    echo "Prediction GPU node pool destruction failed. Trying again in 30 seconds."
    sleep 30
done
echo "Prediction GPU node pool destruction finished."

echo "Destroying training GPU node pool..."
until gcloud container node-pools delete training-gpu --quiet --region ${GPU_COMPUTE_REGION}
do
    echo "Training GPU node pool destruction failed. Trying again in 30 seconds."
    sleep 30
done
echo "Training GPU node pool destruction finished."

echo "Destroying elasticsearch CPU node pool..."
until gcloud container node-pools delete elasticsearch-cpu --quiet --region ${GKE_COMPUTE_REGION}
do
    echo "Elasticsearch-data CPU node pool destruction failed. Trying again in 30 seconds."
    sleep 30
done
echo "Elasticsearch CPU node pool destruction finished."

echo "Destroying redis-consumer, data-processing CPU node pool..."
until gcloud container node-pools delete rc-dp-cpu --quiet --region ${GKE_COMPUTE_REGION}
do
    echo "Redis-consumer, data-processing CPU node pool destruction failed. Trying again in 30 seconds."
    sleep 30
done
echo "Redis-consumer, data-processing CPU node pool destruction finished."
