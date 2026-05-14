# gcp-streaming-new.
[![Blue Ocean Master](http://10.101.120.2:8080/blue/organizations/jenkins/gcp-streaming-new/activity/)]
Updated  layout for gcp streaming code


To build new docker image 
	build.sh XXX where XXX is the version number to build

Creating new filters or upating existing filters
	Create or update test program in ./src/test/python/dq directory for program to modify
	Update code for changes needed
	Run build-test.sh (will build with version tag of username-test)
	Run start-test.sh (will start docker container gcp-cloud-test-USER where USER is your username)
	Run run_tests.sh (will run all tests it finds under test directory - best practice)
	To run individual test - docker exec to container and run test in python.

For batch processing
	Create new script to run in src/main/scripts
	Create new program to run in src/main/python/XXX
	Run build.sh version number
	Run start.sh version-number
	Run docker-exec gcp-cloud-batch sh +x ./script-name

For new DQ flows
	Create property file in src/main/resources - request move to /opt/docker/resources
	Create any new filters needed as detailed above
	Create run script in src/main/scripts - must set environment variables for 
		GOOGLE_APPLICATION_CREDENTIALS
		DQ_PROPERTY_FILE
	Create new start script - start-XXXX-dq.sh

For new Ramps
	Create property file in src/main/resources - request move to /opt/docker/resources
	Create run script in src/main/scripts - must set environment variables for 
		GOOGLE_APPLICATION_CREDENTIALS
		DQ_PROPERTY_FILE
		LD_LIBRARY_PATH (if dependent upon 3rd party libraries like Oracle)
	Create new start script - start-XXX-ramp.sh
