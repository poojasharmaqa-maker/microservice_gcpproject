def build_time = ''
pipeline {
    parameters {
        string(name: 'cloud_function_name', defaultValue: 'function-trigger-dr-etl-staging', description: 'Cloud Function name that you want to focus')
    }
    environment {
    // PROJECT = "REPLACE_WITH_YOUR_PROJECT_ID"
     // This is test file 
        // this is another test
    APP_NAME = "DaaS-gcp-streaming-new"
    // FE_SVC_NAME = "${APP_NAME}-frontend"
    SYS_CLUSTER = "equpiisys-minerva-1"
    SYS_CLUSTER_ZONE = "us-east4-b"
    SYS_TRIGGER_BUCKET = "dr-daily-ingestion-equpiisys"
    PROD_TRIGGER_BUCKET = "dr-daily-ingestion-equ-prd"
    PROD_CLUSTER = "equprd-minerva-1"
    PROD_CLUSTER_ZONE = "us-east4-b"
    // IMAGE_TAG = "gcr.io/${PROJECT}/${APP_NAME}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
    JENKINS_CRED = "${PROJECT}"
    SYS_PROJECT = "svc-equ-pii-sys"
    PROD_PROJECT = "svc-equ-prd"
    BRANCH_NAME = "${env.BRANCH_NAME}"
    GIT_COMMIT = "${env.GIT_COMMIT}"
    IMAGE_TAG = "${GIT_COMMIT}"
  }

  agent {
    kubernetes {
      inheritFrom 'test-deployment'
      defaultContainer 'jnlp'
      yaml """
      apiVersion: v1
      kind: Pod
      metadata:
      labels:
        component: ci
      spec:
        # Use service account that can deploy to all namespaces
        serviceAccountName: cd-jenkins
        hostAliases:
        - ip: "10.81.28.214"
          hostnames:
          - "github.digitalriverws.net"
        containers:
        - name: python
          image: python:3.7
          command:
          - cat
          tty: true
        - name: gcloud
          image: gcr.io/cloud-builders/gcloud
          command:
          - cat
          tty: true
        - name: kubectl
          image: gcr.io/cloud-builders/kubectl
          command:
          - cat
          tty: true
      """
    }
  }
  stages {
    stage('Deploy Cloud Functions Dev') {
      when {
        beforeAgent true
        allOf{
          changeset pattern: "src/main/python/cloud_functions/**"
          branch 'PR-*'
        }
      }
      steps {
        container('gcloud') {
          script{
            // sh "gcloud functions delete ${params.cloud_function_name} --region us-central1"
            sh "cd src/main/python/cloud_functions && gcloud functions deploy ${params.cloud_function_name} --trigger-resource ${SYS_TRIGGER_BUCKET} --trigger-event google.storage.object.finalize --runtime python37 --service-account=svc-equ-piisys-cloudfunction@svc-equ-pii-sys.iam.gserviceaccount.com --entry-point gcs_event_trigger_dag --region=us-east4 --env-vars-file .env-sys.yaml"
        
          }
        }
      }
    }
    stage('Deploy Cloud Functions Master') {
      when {
        beforeAgent true
        allOf{
          changeset pattern: "src/main/python/cloud_functions/**"
          branch 'master' 
        }
      }
      steps {
        container('gcloud') {
          script{
            // sh "gcloud functions delete ${params.cloud_function_name} --region us-central1"
            sh "cd src/main/python/cloud_functions && gcloud functions deploy ${params.cloud_function_name} --trigger-resource ${PROD_TRIGGER_BUCKET} --trigger-event google.storage.object.finalize --runtime python37 --service-account=svc-equ-prd-cloudfunction@svc-equ-prd.iam.gserviceaccount.com --entry-point gcs_event_trigger_dag --region=us-east4 --env-vars-file .env-prod.yaml"
        
          }
        }
      }
    }
    stage('Run Validation') {
      when {
        beforeAgent true
        allOf{
          changeset pattern: "src/test/**"
          // branch 'master' 
        }
      }
      steps {
        container('python'){
          script {
            def local_branch = "${env.BRANCH_NAME}"
            echo "Local branch is ${local_branch}"
            sh "mkdir ../test-workspace/"
            sh "cp ./src/test/python/*/*.py ../test-workspace/"
            sh "cp ./src/main/python/*/*.py ../test-workspace/"
            sh "chmod -R 777 ../test-workspace"
            sh "pip install pytest"
            sh "pip install -r requirements.txt" 
            // sh "git fetch origin --no-tags ${local_branch}"
            sh "git config --global --add safe.directory /home/jenkins/agent/workspace/gcp-streaming-new_${local_branch}"  
            echo "added /home/jenkins/agent/workspace/gcp-streaming-new_master safe.directory"    
            def git_diff = sh (
                script: "git diff-tree --no-commit-id --name-only -r ${env.GIT_COMMIT}",
                returnStdout: true
            ).trim()
            def changed_file_list = git_diff.split()
            for (int i = 0; i < changed_file_list.size(); i++){
              if (changed_file_list[i].contains('src/test/python')){
                echo "${changed_file_list[i]}"
                def python_file = changed_file_list[i].split('/').last()
                println("Validating ${python_file}")
                // sh "ls"
                sh "pytest ../test-workspace/${python_file}"
              }
            }
          }
        }
      }
    }
    stage('Build and push image with Container Builder Dev') {
      when { 
        beforeAgent true
        // not { branch 'master' } 
        allOf{
          changeset pattern: "deployment/**"
          branch 'PR-*'
        }
      }
      steps {
        // input {
        //   message "Should we continue for ${env.BRANCH_NAME}?"
        //   ok "Yes, go ahead."
        // }
        container('gcloud') {
          script{
            build_time = sh (
              script: "date +'%Y-%m-%d-%H-%M-%S'",
              returnStdout: true
            ).trim()
            sh "gcloud builds submit --config=cloudbuild.yaml --substitutions=_IMAGE_TAG=${build_time}-${IMAGE_TAG},_PROJECT=${SYS_PROJECT} --gcs-log-dir=gs://svc-equ-pii-sys_cloudbuild/sys_logs/"
          }
        }
      }
    }
    stage('Build and push image with Container Builder Master') {
      when { branch 'master' }
      steps {
        container('gcloud') {
          script{
            build_time = sh (
              script: "date +'%Y-%m-%d-%H-%M-%S'",
              returnStdout: true
            ).trim()
            sh "gcloud builds submit --config=cloudbuild.yaml --substitutions=_IMAGE_TAG=${build_time}-${IMAGE_TAG}-master,_PROJECT=${PROD_PROJECT} --gcs-log-dir=gs://svc-equ-prd_cloudbuild/prod_logs/"
          }
        //   sh "PYTHONUNBUFFERED=1 gcloud builds submit -t ${IMAGE_TAG} ."
        }
      }
    }
    stage('Deploy image Dev') {
      // Canary branch
      when { 
        // not { branch 'master' } 
        beforeAgent true
        // not { branch 'master' } 
        allOf{
          changeset pattern: "deployment/**"
          branch 'PR-*'
        }
      }
      steps {
        container('kubectl') {
          script {
            def local_branch = "${env.BRANCH_NAME}"
            echo "Local branch is ${local_branch}"

            // sh "git fetch origin --no-tags ${local_branch}"
            sh "git config --global --add safe.directory /home/jenkins/agent/workspace/gcp-streaming-new_${local_branch}"  
            echo "added /home/jenkins/agent/workspace/gcp-streaming-new_master safe.directory"    
            def git_diff = sh (
                script: "git diff-tree --no-commit-id --name-only -r ${env.GIT_COMMIT}",
                returnStdout: true
            ).trim()
            echo "Changes are ${git_diff}"
            def changed_file_list = git_diff.split()
            for (int i = 0; i < changed_file_list.size(); i++){
              // echo "Changed file ${changed_file_list[i]}"
              if (changed_file_list[i].contains('deployment') && changed_file_list[i].contains('-sys')){
                echo "changing ${changed_file_list[i]}"
                sh "chmod -R 777 deployment/"
                // sh "ls -al deployment/abandon-cart"
                sh("sed -i.bak 's#gcr.io/svc-equ-pii-sys/gcp-cloud-new:1.0.0#gcr.io/${env.SYS_PROJECT}/gcp-cloud-new:${build_time}-${IMAGE_TAG}#' ${changed_file_list[i]}")
                sh "cat ${changed_file_list[i]}"  
                step([$class: 'KubernetesEngineBuilder', namespace:'default', projectId: env.SYS_PROJECT, clusterName: env.SYS_CLUSTER, zone: env.SYS_CLUSTER_ZONE, manifestPattern: "${changed_file_list[i]}", credentialsId: env.SYS_PROJECT, verifyDeployments: true])
              }
            }
          }
          // Change deployed image in canary to the one we just built
          // step([$class: 'KubernetesEngineBuilder', namespace:'default', projectId: env.SYS_PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'k8s/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
          // step([$class: 'KubernetesEngineBuilder', namespace:'default', projectId: env.SYS_PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'k8s/canary', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
          // sh("echo http://`kubectl --namespace=production get service/${FE_SVC_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'` > ${FE_SVC_NAME}")
        }
      }
    }
    stage('Deploy image production') {
      // Canary branch
      when  { branch 'master' } 
      steps {
        container('kubectl') {
          script {
            def local_branch = "${env.BRANCH_NAME}"
            echo "Local branch is ${local_branch}"
              
            sh "git config --global --add safe.directory /home/jenkins/agent/workspace/gcp-streaming-new_${local_branch}"  
            echo "added /home/jenkins/agent/workspace/gcp-streaming-new_master safe.directory"  

            def merge_commit = sh (
              script: "git show --format='%p'",
              returnStdout: true
            ).trim()
            def commit_list = merge_commit.split(' ')
            // sh "git fetch origin --no-tags ${local_branch}"
            def git_diff = sh (
                script: "git diff-tree --no-commit-id --name-only -r ${commit_list[1]}",
                returnStdout: true
            ).trim()
            def changed_file_list = git_diff.split()
            for (int i = 0; i < changed_file_list.size(); i++){
              // echo "Changed file ${changed_file_list[i]}"
              if (changed_file_list[i].contains('deployment') && changed_file_list[i].contains('-prod')){
                echo "changing ${changed_file_list[i]}"
                sh "chmod -R 777 deployment/"
                // sh "ls -al deployment/abandon-cart"
                sh("sed -i.bak 's#gcr.io/svc-equ-prd/gcp-cloud-new:1.0.0#gcr.io/${env.PROD_PROJECT}/gcp-cloud-new:${build_time}-${IMAGE_TAG}-master#' ${changed_file_list[i]}")
                sh "cat ${changed_file_list[i]}"
                env.DECISION = input message:"Should we continue to deploy in production?", ok: "Yes, go ahead."
                step([$class: 'KubernetesEngineBuilder', namespace:'default', projectId: env.PROD_PROJECT, clusterName: env.PROD_CLUSTER, zone: env.PROD_CLUSTER_ZONE, manifestPattern: "${changed_file_list[i]}", credentialsId: env.PROD_PROJECT, verifyDeployments: true])
              }
            }
          }
          // Change deployed image in canary to the one we just built
          // step([$class: 'KubernetesEngineBuilder', namespace:'default', projectId: env.SYS_PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'k8s/services', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
          // step([$class: 'KubernetesEngineBuilder', namespace:'default', projectId: env.SYS_PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'k8s/canary', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
          // sh("echo http://`kubectl --namespace=production get service/${FE_SVC_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'` > ${FE_SVC_NAME}")
        }
      }
    }
  }
}
