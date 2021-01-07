# Maven tools

A collection of helper scripts for Maven.

* [run-kotlin-main](run-kotlin-main) - Run single-jar Kotlin projects,
  properly picking the JVM class name for a given simplified Kotlin name
  (class names are automatically titlecased, and "Kt" appended if needed):
    - `./run-kotlin-main [-- arguments]` -- runs an executable jar
    - `./run-kotlin-main main-class [arguments]` runs `main` from `main-class`

  Further, if the single jar is out-of-date w.r.t. the source tree,
  automatically run `./mvnw package` before executing.

## Tests

There are no tests.
