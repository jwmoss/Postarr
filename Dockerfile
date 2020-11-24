FROM mcr.microsoft.com/powershell:alpine-3.12
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN apk add --no-cache imagemagick

ARG version
LABEL maintainer="@jwmoss"
LABEL description="Postarr container for Alpine 3.8"
COPY ["postarr.psm1", "/opt/microsoft/powershell/7/Modules/Postarr/"]
COPY ["docker_entrypoint.ps1", "docker_entrypoint.ps1"]
VOLUME ["/data"]
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
SHELL ["pwsh", "/docker_entrypoint.ps1"]