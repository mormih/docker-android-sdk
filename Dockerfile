FROM ubuntu:16.04
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_VERSION 26.0.2
ENV MAX_SDK_VERSION 26
ENV MIN_SDK_VERSION 15


# ------------------------------------------------------
# --- Install required tools
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository -y ppa:git-core/ppa
RUN apt-get update -qq

# Dependencies to execute Android builds
#RUN dpkg --add-architecture i386
#RUN DEBIAN_FRONTEND=noninteractive apt-get libc6:i386 libc6-dbg:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386
#RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk wget curl expect git-all unzip lib32stdc++6 libc6-dbg
# Install git-lfs plugin
RUN cd /opt && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && apt-get install -y git-lfs
RUN git config --global user.email "builder@noemail.com"
RUN git config --global user.name "builder"
# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME

RUN cd /opt && wget -q https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
RUN cd /opt && mkdir android-sdk-linux && cd android-sdk-linux && mkdir add-ons && mkdir platforms
RUN cd /opt && unzip tools_r${ANDROID_VERSION}-linux.zip -d android-sdk-linux
RUN cd /opt && rm -f tools_r${ANDROID_VERSION}-linux.zip

RUN cd /opt && wget -q https://dl.google.com/android/android-sdk_r$25.2.3-linux.tgz -O android-sdk.tgz
RUN cd /opt && tar -xvzf android-sdk.tgz
RUN cd /opt && rm -f android-sdk.tgz

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools


# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  android list sdk --no-ui --all --extended
# (!!!) Only install one package at a time, as "echo y" will only work for one license!
#       If you don't do it this way you might get "Unknown response" in the logs,
#         but the android SDK tool **won't** fail, it'll just **NOT** install the package.

# build tools
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter build-tools-${ANDROID_VERSION} | grep 'package installed'

# SDKs
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter android-${MAX_SDK_VERSION} | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter android-${MIN_SDK_VERSION} | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter android-24 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter android-23 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter android-18 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter android-16 | grep 'package installed'

# platform tools
RUN echo y | android update sdk --no-ui --all --filter platform-tools | grep 'package installed'

# Android System Images, for emulators
# Please keep these in descending order!
#RUN echo y | android update sdk --no-ui --all --filter sys-img-x86_64-android-25 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter sys-img-x86-android-25 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-25 | grep 'package installed'

#RUN echo y | android update sdk --no-ui --all --filter sys-img-x86_64-android-24 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter sys-img-x86-android-24 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-24 | grep 'package installed'

#RUN echo y | android update sdk --no-ui --all --filter sys-img-x86-android-23 | grep 'package installed'
#RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-23 | grep 'package installed'

# Extras
#RUN echo y | android update sdk --no-ui --all --filter extra-android-support | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter extra-android-m2repository | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter extra-google-m2repository | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter extra-google-google_play_services | grep 'package installed'

# install those?

# build-tools-21.0.0
#build-tools-21.0.1
#build-tools-21.0.2
#build-tools-21.1.0
#build-tools-21.1.1
#build-tools-21.1.2
#build-tools-22.0.0
#build-tools-22.0.1
#build-tools-23.0.0
#build-tools-23.0.1
#build-tools-23.0.2
#build-tools-23.0.3
#build-tools-24.0.0
#build-tools-24.0.1
#build-tools-24.0.2
#android-21
#android-22
#android-23
#android-24
#addon-google_apis-google-24
#addon-google_apis-google-23
#addon-google_apis-google-22
#addon-google_apis-google-21
#extra-android-support
#extra-android-m2repository
#extra-google-m2repository
#extra-google-google_play_services
#sys-img-arm64-v8a-android-24
#sys-img-armeabi-v7a-android-24
#sys-img-x86_64-android-24
#sys-img-x86-android-24

# google apis
# Please keep these in descending order!
#RUN echo y | android update sdk --no-ui --all --filter addon-google_apis-google-24 | grep 'package installed'

# Copy install tools
COPY tools /opt/tools

#Copy accepted android licenses
COPY licenses/android-sdk-license ${ANDROID_HOME}
COPY licenses/android-sdk-preview-license ${ANDROID_HOME}

ENV PATH ${PATH}:/opt/tools
# Update SDK
# RUN /opt/tools/android-accept-licenses.sh android update sdk --no-ui --obsolete --force


RUN mkdir /opt/build-tools/
COPY gradle /opt/build-tools/gradle
COPY gradlew /opt/build-tools/

RUN /opt/build-tools/gradlew tasks

RUN apt-get clean

RUN chown -R 1000:1000 $ANDROID_HOME
VOLUME ["/opt/android-sdk-linux"]
