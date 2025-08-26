# Defense Builders SDK - ATAK-CIV
# Android Tactical Assault Kit (Civil) Development Environment
# https://github.com/iotactical/defense-builders-sdk

FROM ghcr.io/iotactical/dbsdk-base:latest

LABEL org.opencontainers.image.source="https://github.com/iotactical/defense-builders-sdk"
LABEL org.opencontainers.image.description="DBSDK ATAK-CIV Development Environment"
LABEL org.opencontainers.image.licenses="MIT"

# ATAK-CIV specific environment
ENV DBSDK_SDK_TYPE=atak-civ
ENV DBSDK_SDK_VERSION=4.10.0
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

USER root

# Install Java 17 and Android development tools
RUN apt-get update && apt-get install -y \
    # Java 17 (LTS)
    openjdk-17-jdk \
    # Android development dependencies  
    lib32stdc++6 \
    lib32z1 \
    # Build tools
    gradle \
    maven \
    # Additional utilities
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install Android SDK
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    cd $ANDROID_HOME/cmdline-tools && \
    curl -o android-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip && \
    unzip android-tools.zip && \
    mv cmdline-tools latest && \
    rm android-tools.zip

# Accept Android licenses and install required components
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses && \
    $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
        "platform-tools" \
        "platforms;android-30" \
        "platforms;android-33" \
        "build-tools;30.0.3" \
        "build-tools;33.0.1"

# Clone ATAK-CIV repository
RUN mkdir -p /opt/atak-civ && \
    git clone https://github.com/deptofdefense/AndroidTacticalAssaultKit-CIV.git /opt/atak-civ && \
    chown -R vscode:vscode /opt/atak-civ

# Copy ATAK-CIV specific scripts
COPY scripts/ /opt/dbsdk/atak-civ/scripts/
RUN chmod +x /opt/dbsdk/atak-civ/scripts/*

# Set up ATAK development environment
RUN /opt/dbsdk/atak-civ/scripts/setup-atak.sh

# Switch back to vscode user
USER vscode

# Set working directory to workspaces
WORKDIR /workspaces

# ATAK-CIV specific health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD /opt/dbsdk/atak-civ/scripts/healthcheck-atak.sh

# Welcome message
RUN echo 'echo "ATAK-CIV Development Environment Ready!"' >> ~/.bashrc && \
    echo 'echo "ATAK-CIV source: /opt/atak-civ"' >> ~/.bashrc && \
    echo 'echo "Start developing: Create your plugin in /workspaces"' >> ~/.bashrc && \
    echo 'echo "Documentation: https://github.com/deptofdefense/AndroidTacticalAssaultKit-CIV"' >> ~/.bashrc

CMD ["/bin/bash"]