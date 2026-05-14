if [ "$#" -ne 3 ]  
then
	echo "wrong number of parameters"
	exit 100
fi
HISTORY=$1
START=$2
END=$3
HISTORY_=`echo $HISTORY | tr - _`
echo $HISTORY_
gcloud container clusters get-credentials minerva-1 --zone us-central1-a --project artful-affinity-219719
if [ "$?" -ne 0 ]
then
	echo "could not set kubernetes properly - make sure api installed"
	exit 200
fi
echo "getting pods"
POD=`kubectl get pods | grep $HISTORY | grep lambda  | grep Running | cut -f1 -d " " | head -1`
echo "pod is $POD"
POD_CHECK=`echo $POD | wc -m`
echo "pod check is $POD_CHECK"
if [ "$POD_CHECK" -eq 1 ]
then
	echo "Could not find running component for history - bailing"
	exit 300
fi
echo "running history command"
kubectl exec $POD ./run_oracle_to_pubsub_lambda.sh  ${HISTORY_}_candidates_history.properties "$START" "$END"
