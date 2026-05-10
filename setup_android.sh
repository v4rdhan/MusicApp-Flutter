#!/bin/bash
# Install Java
mkdir -p ~/java
cd ~/java
if [ ! -d "jdk-17.0.2" ]; then
    wget -q https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz
    tar xzf openjdk-17.0.2_linux-x64_bin.tar.gz
    rm openjdk-17.0.2_linux-x64_bin.tar.gz
fi
export JAVA_HOME="$HOME/java/jdk-17.0.2"
export PATH="$JAVA_HOME/bin:$PATH"

# Setup Android
mkdir -p ~/Android/Sdk/cmdline-tools
cd ~/Android/Sdk/cmdline-tools
if [ ! -d "latest" ]; then
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
    unzip -q cmdline-tools.zip
    rm cmdline-tools.zip
    mv cmdline-tools latest
fi

export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Flutter config and pub get
cd /home/v4rdhan/Desktop/Android/1-MusicApp-Flutter
export PATH="$PATH:$HOME/flutter/bin"
flutter config --no-analytics
flutter pub get
