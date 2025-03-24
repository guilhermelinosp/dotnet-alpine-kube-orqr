FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app
RUN apt update -y && apt install -y --no-install-recommends clang gcc zlib1g-dev 

COPY *.csproj ./
RUN dotnet restore *.csproj -r linux-x64

COPY . .
RUN dotnet publish *.csproj -c Release -r linux-x64 -o /app/publish \
    --no-restore \
    /p:UseAppHost=true \
    /p:PublishAot=true \
    /p:PublishTrimmed=true \
    /p:StripSymbols=true \
    /p:OptimizationPreference=Size

FROM alpine:3.21 AS runner
EXPOSE 80
RUN apk add --no-cache \
    libstdc++ \
    libgcc \
    libc6-compat \
    && addgroup -S appgroup \
    && adduser -S -G appgroup -h /app appuser
COPY --from=build --chown=appuser:appgroup /app/publish/demo-aot-api /app/appsettings.json /app/
USER appuser
WORKDIR /app
ENV ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS="http://+:80" \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true \
    DOTNET_gcServer=1 \
    DOTNET_gcConcurrent=1
CMD ["./demo-aot-api"]