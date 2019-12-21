## Dec 20 2019, Create Gex project

```terminal
mix new gex --umbrella
```

- https://elixirschool.com/en/lessons/advanced/umbrella-projects/
- `cd apps && mix new tools`
- say `build_path: "custom_build_dir"` in top level mix.exs and inside tools

## Dec 19 2019, Install Elixir

On Ubuntu, after doing `apt install erlang elixir` we often end up with wrong
version of Elixir, that is one that was not comliled with installed Erlang.
One of many ways to solve this problem is to use `asdf` package manager.

First, install Erlang:
```terminal
sudo apt install erlang
```

Then run `erl` and get its OTP version, say it is 20.
After that install corresponding version of Elixir:

```terminal
asdf plugin-add elixir
asdf install elixir 1.9.4-otp-20
asdf global elixir 1.9.4-otp-20
```
