# Architecture

## Core modules

- `Persistence`: encapsulates the persistence interface
- `WebInterface`
- `IncomingWebhooks`
- `Workflows`
- `Integrations`: this module enables the extension of the Letto engine with new integration to external services and components.

## Principles

- All effects (e.g. persistence changes, external API calls) must be triggered through the usage of `Commands`.
- `Commands` may only be executed by responding to `Events`.

## Integrations structure

An integration module, `Integrations::SampleIntegration` may contain the following modules to extend core Letto features:

- `WebInterface`: defines routes to add to the `Letto::WebInterface` Sinatra application.
- `Persistence`: enrichments to be stored through Letto's persistence
- `Commands`: the commands for this integration
- `Events`: business events that may be triggered in the context of the integration

## WebInterface modules

- Must contain a `Helpers` module for the helpers to be loaded for the Sinatra route methods.
- Must defined a `register_routes(app)` method which is passed the Sinatra app to dynamically add the appropriate routes.
