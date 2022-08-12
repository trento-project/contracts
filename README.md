# Trento contracts

This repository contains the contracts, with validation of comm messages between trento services.

# Generate go contracts with validationn

You should use the handy tool called trento-contracts-generator

```bash
cd go && go run cmd/trento-contracts-generator/main.go -fileName <output_filename>.go ../schema/<your_schema.json>
```

You will find your generated contract in `go/pkg/entities/<output_filename.go>`


# Available contracts

- trento.checks.v1.FactsRequest.schema: The request for fact gathering sent by `wanda` to the `agent`