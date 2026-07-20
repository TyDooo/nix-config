Monitoring service based on the clan.lol [monitoring service](https://git.clan.lol/clan/clan-core/src/branch/main/clanServices/monitoring).

## Inputs

The service collects `metric_endpoint` (name TBD) inputs from other clan services, allowing them to register their own metric endpoints.

## Architecture Overview

```mermaid
---
  config:
    class:
      hideEmptyMembersBox: true
---
classDiagram
    namespace server {
        class `Visualization & Alerting` {<<Grafana>>}
        class `Log Storage` {<<Grafana Loki>>}
        class `Metrics Storage` {<<Grafana Mimir>>}
    }

    namespace client {
        class `Log & Metrics Collector` {<<Grafana Alloy>>}
        class `systemd services`
        class `system metrics`
        class `Third-Party service`
    }

    `Visualization & Alerting` --> `Metrics Storage` : metrics
    `Visualization & Alerting` --> `Log Storage` : logs
    `Log Storage` <-- `Log & Metrics Collector` : logs
    `Metrics Storage` <-- `Log & Metrics Collector` : metrics
    `Log & Metrics Collector` --> `system metrics` : metrics
    `Log & Metrics Collector` --> `systemd services` : metrics & logs
    `Log & Metrics Collector` --> `Third-Party service` : metrics (endpoint)
```

## Roles

### Server

The servers collect and store metrics and logs from the client machines.
They also provide Grafana dashboards for visualization and alerting.

### Client

Clients are machines that create metrics and logs.
