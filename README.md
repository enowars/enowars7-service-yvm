# yvm

An [attack-defense CTF](https://ctftime.org/ctf-wtf/) service revolving around
a toy JVM written in OCaml that was played at [ENOWARS 7](https://ctftime.org/event/2040).

The service was written in the context of the
[International Information Security Contest](https://moseskonto.tu-berlin.de/moses/modultransfersystem/bolognamodule/beschreibung/anzeigen.html?nummer=40933&version=4&sprache=2)
university course.

- `service/` contains the service. This folder was deployed on the hosts of the participants.
- `checker/` contains the [checker](https://enowars.github.io/docs/service/getting-started/#checker) that was run centrally.
- `documentation/` Describes the service and vulnerabilities and contains the slides for my presentation after the test run and my final presentation.

See [documentation/README.md](documentation/README.md) for architecture, features, and vulns.
