FROM ubuntu:16.10

MAINTAINER Lukas Elsner "open@mindrunner.de"

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install java8
RUN apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository -y ppa:webupd8team/java && \
  (echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections) && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  apt-get clean && \
  rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Deps
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --force-yes expect git wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 python curl && apt-get clean && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy install tools
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

# Install Android SDK
RUN cd /opt && wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r24.3.3-linux.tgz && \
  tar xzf android-sdk.tgz && \
  rm -f android-sdk.tgz && \
  chown -R root.root ${ANDROID_HOME} && \
  /opt/tools/android-accept-licenses.sh "${ANDROID_HOME}/tools/android update sdk --all --no-ui --filter platform-tools,tools" && \
  /opt/tools/android-accept-licenses.sh "${ANDROID_HOME}/tools/android update sdk --all --no-ui --filter build-tools-21.0.0,build-tools-21.0.1,build-tools-21.0.2,build-tools-21.1.0,build-tools-21.1.1,build-tools-21.1.2,build-tools-22.0.0,build-tools-22.0.1,build-tools-23.0.0,build-tools-23.0.1,build-tools-23.0.2,build-tools-23.0.3,build-tools-24.0.0,build-tools-24.0.1,build-tools-24.0.2,android-21,android-22,android-23,android-24,addon-google_apis-google-24,addon-google_apis-google-23,addon-google_apis-google-22,addon-google_apis-google-21,extra-android-support,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services,sys-img-arm64-v8a-android-24,sys-img-armeabi-v7a-android-24,sys-img-x86_64-android-24,sys-img-x86-android-24"
# RUN /opt/tools/android-accept-licenses.sh "${ANDROID_HOME}/tools/android update sdk --all --no-ui"



RUN which adb
RUN which android

# Create emulator
RUN echo "no" | android create avd \
                --force \
                --device "Nexus 5" \
                --name test \
                --target android-24 \
                --abi armeabi-v7a \
                --skin WVGA800 \
                --sdcard 512M

# Cleaning
RUN apt-get clean

RUN chown -R 1000:1000 ${ANDROID_HOME}

VOLUME ["${ANDROID_HOME}"]
