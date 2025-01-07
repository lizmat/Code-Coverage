use Telemetry;
use Code::Coverage;
use BUILDPLAN;

say @*ARGS
  ?? BUILDALLPLAN(Telemetry)
  !! BUILDPLAN(Code::Coverage);

# vim: expandtab shiftwidth=4
