Phoenix powered "match game" to show off what I've learned writing Elixir the last few months

```bash
git clone https://github.com/toranb/elixir-match.git example
```

To run the Phoenix app with mix

1) install elixir

```bash
brew install elixir
```

2) install postgres

```bash
brew install postgres
```

3) install dependencies

```bash
cd app
mix deps.get
```

4) run ecto create/migrate

```bash
cd app
mix ecto.create
mix ecto.migrate
```

5) start phoenix

```bash
cd app
iex -S mix phx.server
```

6) Use `elixir2019` as invite code in login screen.

To run the app with docker

1) install docker

    https://docs.docker.com/docker-for-mac/

2) build and run the app with docker

```bash
docker-compose build
docker-compose up
```
