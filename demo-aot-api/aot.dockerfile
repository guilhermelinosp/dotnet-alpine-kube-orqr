# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine3.18 AS build
ARG TARGETARCH
RUN apk add --no-cache clang gcc musl-dev zlib-dev
WORKDIR /app
COPY *.csproj ./
RUN dotnet restore *.csproj -r linux-musl-${TARGETARCH:-x64}
COPY . .
RUN dotnet publish *.csproj -c Release -r linux-musl-${TARGETARCH:-x64} -o /app/publish \
    --no-restore \
    /p:UseAppHost=true \
    /p:PublishAot=true \
    /p:StripSymbols=true
RUN ls -la /app/publish

# Runtime stage
FROM alpine:3.18 AS runner
EXPOSE 80
RUN apk add --no-cache tini \
    && addgroup -S appgroup && adduser -S -G appgroup appuser
COPY --from=build --chown=appuser:appgroup /app/publish /app/
USER appuser
WORKDIR /app
ENV ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["./demo-aot-api"]