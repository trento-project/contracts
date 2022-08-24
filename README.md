# Trento contracts

This repository contains the contracts, with validation of comm messages between trento services.

# Generate go contracts with validation

You should use the handy tool called trento-contracts-generator

```bash
cd go && go run cmd/trento-contracts-generator/main.go -fileName <output_filename> ../schema/<your_schema.json>
```

You will find your generated contract in `go/pkg/gen/entities/<output_filename.go>`

# The schema file naming convention

Schema files, contained into the `schema` directory should follow this naming convention

`trento.[project].[version].[source].[SchemaName].schema.json`

For example

`trento.checks.v1.wanda.FactRequest.schema.json`


# Available contracts

- trento.checks.v1.wanda.FactsRequest.schema: The request for fact gathering sent by `wanda` to the `agent`
- trento.checks.v1.agent.FactsGathered.schema: The result of a fact gathering request  sent by `agent` to `wanda`
