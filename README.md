# Trento Contracts

# How to generate the interfaces

Follow the next steps in order to generate the final code interfaces from the [protobuf definitions](./protobuf/).

## Pre-requirements

- Install [asdf](https://asdf-vm.com/guide/getting-started.html) and add all the needed plugins:

```
asdf plugin add elixir
asdf plugin add erlang
asdf plugin add golang
asdf plugin add protoc
asdf plugin add protoc-gen-go
```

- Define `golang` version to `asdf` to enable `protoc-gen-go` usage. For that, edit `$HOME/.asdf/.tool-versions` and append the next line:

```
golang 1.23.6
```

- Install the required tool versions running:

```
asdf install
```

- Install and configure `protoc-gen-elixir` running:

```
mix escript.install hex protobuf
asdf reshim
```

## Generate the code

Once all the tools are installed, run the next command to update the final code interfaces:

```
make
```

In order to make the last command work, `protoc-gen-go` and `protoc-gen-elixir` must be available in your PATH system variable (they are if they are installed using the previously explained `asdf` option).