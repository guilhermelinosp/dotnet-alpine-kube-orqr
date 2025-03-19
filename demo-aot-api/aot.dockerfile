# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine3.18 AS build
RUN apk add --no-cache clang gcc musl-dev zlib-dev
WORKDIR /app
COPY ./*.csproj ./
RUN dotnet restore *.csproj -r linux-musl-x64
COPY . .
RUN dotnet publish *.csproj -c Release -r linux-musl-x64 -o /app/publish --no-restore
RUN ls -la /app/publish

# Runtime stage
FROM alpine:3.18 AS runner
EXPOSE 80
COPY --from=build /app/publish /app/
RUN chmod +x /app/demo-aot-api
ENV ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS=http://*:80 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
CMD ["./app/demo-aot-api"]