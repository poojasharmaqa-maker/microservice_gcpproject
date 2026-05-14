ARG PROJECT_ID
ARG FOLDER
ARG BASE_REPO_NAME

FROM us-east4-docker.pkg.dev/${PROJECT_ID}/${FOLDER}/${BASE_REPO_NAME}:base16

LABEL maintainer="Suren Meesala <smeesala@digitalriver.com>"

ADD ./src/main/scripts/* ./
ADD ./src/main/python/* ./
# ADD ./src/test/python/*/*.py ./
ADD ./*.conf ./
ADD ./src/main/resources/* /resources/
#ADD ./IP2Location/* ./
ADD ./IP2Location/data/* ./data/
RUN dos2unix *.sh
RUN chmod +x *.sh
