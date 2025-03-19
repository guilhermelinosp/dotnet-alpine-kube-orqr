FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

COPY ["demo-jit-api/demo-jit-api.csproj", "demo-jit-api/"]
RUN dotnet restore "demo-jit-api/demo-jit-api.csproj"
COPY . .
RUN dotnet build "demo-jit-api/demo-jit-api.csproj" -c Release -o /app/build
RUN dotnet publish "demo-jit-api/demo-jit-api.csproj" -c Release -o /app/publish /p:PublishSingleFile=true /p:RuntimeIdentifier=linux-x64

FROM alpine:3.18 AS runner
ENV ASPNETCORE_ENVIRONMENT=Production
COPY --from=build /app/publish .
ENTRYPOINT ["/app/demo-jit-api"]