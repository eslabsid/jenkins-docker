# Use Jenkins latest
FROM jenkins/jenkins:latest

LABEL maintainer Edi Septriyanto <eslabs.id@gmail.com> architecture="AMD64/x86_64"
LABEL jenkins-version="latest" debian-version="stretch" build="25-Jan-2020"

USER root

ENV JENKINS_REF /usr/share/jenkins/ref

# Install Docker
RUN apt-get -y update && \
    apt-get -y install apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "${ID}")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
    apt-get -y update && \
    apt-get -y install docker-ce

# Skip the setup wizard
# ENV JAVA_ARGS -Djenkins.install.runSetupWizard=false -Dpermissive-script-security.enabled=true
# ENV JAVA_ARGS -Djenkins.install.runSetupWizard=false
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Dpermissive-script-security.enabled=true"

# Install the plugins
COPY jenkins-home/plugins.txt ${JENKINS_REF}/
RUN /usr/local/bin/install-plugins.sh < ${JENKINS_REF}/plugins.txt

COPY jenkins-home/email-templates /var/jenkins_home/

RUN usermod -a -G docker jenkins
USER jenkins
