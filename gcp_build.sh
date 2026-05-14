VERSION=$1
gcloud builds submit --tag gcr.io/artful-affinity-219719/gcp-cloud-new:$VERSION
