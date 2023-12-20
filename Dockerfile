#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.hamdocker.ir/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.hamdocker.ir/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Yalda/Yalda/Yalda.csproj", "Yalda/Yalda/"]
COPY ["Yalda/Yalda.Client/Yalda.Client.csproj", "Yalda/Yalda.Client/"]
RUN dotnet restore "./Yalda/Yalda/Yalda.csproj"
COPY . .
WORKDIR "/src/Yalda/Yalda"
RUN dotnet build "./Yalda.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Yalda.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Yalda.dll"]