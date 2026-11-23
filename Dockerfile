FROM dart:stable AS build
WORKDIR /app
COPY backend/pubspec.* ./
RUN dart pub get
COPY backend/ .
COPY database/migrations/ /app/migrations/
RUN dart compile exe bin/server.dart -o bin/server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server
COPY --from=build /app/migrations /app/migrations
EXPOSE 8080
CMD ["/app/bin/server"]
