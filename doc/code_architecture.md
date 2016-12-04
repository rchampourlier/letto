# Architecture

## Core modules

- `Persistence`: encapsulates the persistence interface
- `WebInterface`
- `IncomingWebhooks`
- `Workflows`
- `Integrations`: this module enables the extension of the Letto engine with new integration to external services and components.

## Principles

- Anything that performs a side-effect (like an API call or a persistence) must
  be triggered within an `Event`.

## Integrations structure

An integration module, `Integrations::SampleIntegration` may contain the following modules to extend core Letto features:

- `WebInterface`: defines routes to add to the `Letto::WebInterface` Sinatra application.
- `Persistence`: enrichments to be stored through Letto's persistence
- `Commands`: the commands for this integration
- `Events`: business events that may be triggered in the context of the integration

## WebInterface modules

- Must contain a `Helpers` module for the helpers to be loaded for the Sinatra route methods.
- Must defined a `register_routes(app)` method which is passed the Sinatra app to dynamically add the appropriate routes.
