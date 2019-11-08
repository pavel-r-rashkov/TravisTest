FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /app

# copy csproj files
COPY src/*.sln .
COPY src/Web/*.csproj ./Web/
COPY src/Test/*.csproj ./Test/
RUN dotnet restore

# copy rest of files
COPY src/Web/. ./Web/
COPY src/Test/. ./Test/

RUN dotnet build

# test
FROM build AS test
WORKDIR /app/Test
RUN dotnet test

# publish
FROM build AS publish
WORKDIR /app/Web
RUN dotnet publish -o out

# run
FROM microsoft/dotnet:2.1-runtime AS runtime
WORKDIR /app
COPY --from=publish /app/Web/out ./
EXPOSE 80
ENTRYPOINT ["dotnet", "Web.dll"]
