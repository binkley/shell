package hm.binkley;

import joptsimple.OptionParser;
import joptsimple.OptionSet;
import joptsimple.OptionSpecBuilder;

import java.io.PrintStream;

import static java.lang.String.format;
import static java.lang.System.err;
import static java.lang.System.exit;

public final class Main {
    private static void printUsage(final String program,
            final PrintStream printer) {
        printer.println(
                format("Usage: %s [--health][--resume] job-name [args]",
                        program));
    }

    public static void main(final String... args) {
        final OptionParser parser = new OptionParser();
        final OptionSpecBuilder healthFlag = parser.accepts("health");
        final OptionSpecBuilder resumeFlag = parser.accepts("resume");

        final OptionSet options = parser.parse(args);
        final String[] realArgs = options.nonOptionArguments().
                toArray(new String[0]);

        final String jobName;
        switch (realArgs.length) {
        case 1:
            jobName = realArgs[0];
            break;
        default:
            printUsage("test-program", err);
            exit(2);
            return;
        }

        switch (jobName) {
        case "healthy-job":
        case "unhealthy-job":
        case "resumable-job":
        case "unresumable-job":
            break;
        default:
            err.println(format("test-program: Not a job: %s", jobName));
            exit(2);
        }

        if (options.has(healthFlag)) {
            switch (jobName) {
            case "unhealthy-job":
                err.println(format("%s: I am sad", jobName));
                exit(1);
            default:
                exit(0);
            }
        }

        if (options.has(resumeFlag)) {
            switch (jobName) {
            case "unresumable-job":
                err.println(format("%s: Resume not supported", jobName));
                exit(2);
            default:
                exit(0);
            }
        }
    }
}
