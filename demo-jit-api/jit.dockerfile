FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

COPY *.csproj ./
RUN dotnet restore -r linux-x64

COPY . .
RUN dotnet publish *.csproj -c Release -r linux-x64 -o /app/publish \
    --no-restore \
    /p:UseAppHost=true \
    /p:PublishSingleFile=true \
    /p:PublishTrimmed=true \
    /p:SelfContained=true 

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runner
WORKDIR /app

RUN useradd -ms /bin/bash appuser
USER appuser

EXPOSE 80

COPY --from=build /app/publish/demo-jit-api /app/demo-jit-api
COPY --from=build /app/appsettings.json /app/appsettings.json

ENV ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS="http://+:80" \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true \
    DOTNET_gcServer=1 \
    DOTNET_gcConcurrent=1

ENTRYPOINT ["./demo-jit-api"]
