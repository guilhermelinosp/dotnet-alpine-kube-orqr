# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine3.21 AS build
ARG TARGETARCH
RUN apk add --no-cache clang gcc musl-dev zlib-dev binutils
WORKDIR /app

COPY *.csproj ./
RUN dotnet restore *.csproj -r linux-musl-${TARGETARCH:-x64}

COPY . .
RUN dotnet publish *.csproj -c Release -r linux-musl-${TARGETARCH:-x64} -o /app/publish \
    --no-restore \
    /p:UseAppHost=true \
    /p:PublishAot=true \
    /p:StripSymbols=true \
    /p:OptimizationPreference=Size \
    && strip -s /app/publish/demo-aot-api

# Runtime stage
FROM alpine:3.21 AS runner
EXPOSE 80
RUN apk add --no-cache tini libstdc++ libgcc \
    && addgroup -S appgroup && adduser -S -G appgroup appuser 
COPY --from=build --chown=appuser:appgroup /app/publish/demo-aot-api /app/demo-aot-api
COPY --from=build --chown=appuser:appgroup /app/appsettings.json /app/appsettings.json
USER appuser
WORKDIR /app
ENV ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS="http://+:80" \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true \
    DOTNET_gcServer=1 \
    DOTNET_gcConcurrent=1
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["./demo-aot-api"]