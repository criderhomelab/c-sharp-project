FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Remove imagemagick due to https://security-tracker.debian.org/tracker/CVE-2019-10131
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get purge -y imagemagick imagemagick-6-common

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends direnv sshpass figlet gnupg2 curl

RUN apt-get update \
    && apt-get install -y dotnet-sdk-8.0

RUN apt-get update \
    && apt-get install -y aspnetcore-runtime-8.0 \
    && apt-get install -y dotnet-runtime-8.0

RUN dotnet tool install --global dotnet-format
