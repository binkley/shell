# Maven tools

A collection of helper scripts for Maven.

* [Kotlin runner](#kotlin-runner) - Run a single-jar Kotlin project

## Kotlin runner

[`run-kotlin-main`](run-kotlin-main) runs a single-jar Kotlin project,
properly picking the JVM class name for a given simplified Kotlin name
(class names are automatically titlecased, and "Kt" appended if needed):

- `./run-kotlin-main [-X ARGUMENTS]` -- runs an executable jar
- `./run-kotlin-main CLASS [ARGUMENTS]` runs `main` from "CLASS"

Further, if the single jar is out-of-date w.r.t. the source tree,
automatically runs `./mvnw package` before executing.

**NB** &mdash; To accommodate both arbitrary options and arguments to
`main`, and treating the first argument as an alternative classname for
`main`, use the `--executable` (`-X`) flag as needed:

1. If there are no flags or arguments to the script, treat the single jar as
   executable
2. If there are flags to the script, use a `--` to stop further processing the
   command line; however the first remaining argument will be treated as a
   classname with remaining flags or arguments passed to `main`
3. The `-X` flag stops all processing, treating the single jar as executable,
   and passes remaining flags or arguments to the jar

Use the `--debug` (`-d`) flag to debug the script:
`./run-kotlin-main -d [-X ARGUMENTS]` or
`./run-kotlin-main -d -- CLASS [ARGUMENTS]`.

See [Apache Maven Assembly Plugin](https://maven.apache.org/plugins/maven-assembly-plugin/)
for instructions on single-jar projects.

### Tests

There are no tests.
