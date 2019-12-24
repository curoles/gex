## Dec 22, NumPy Array

- Did they take idea from [this](https://www.researchgate.net/publication/221211398_High-performance_technical_computing_with_erlang) Erlang design?
- https://www.scipy.org/scipylib/faq.html#id4
- https://sourceforge.net/projects/numpy/files/Old%20Numarray/
- https://sourceforge.net/projects/numpy/files/Old%20Numarray/

## Dec 22, what data can be found in Internet?

- https://medium.com/@pewresearch/using-google-trends-data-for-research-here-are-6-questions-to-ask-a7097f5fb526
- https://www.weatherbit.io/api
- https://github.com/public-apis/public-apis#news
- https://github.com/public-apis/public-apis#weather
- https://github.com/public-apis/public-apis#jobs
- https://github.com/public-apis/public-apis#government
- https://github.com/public-apis/public-apis#environment

## Dec 22, NIF

- http://erlang.org/doc/man/erl_nif.html
- https://cs.mcgill.ca/~mxia3/2017/06/18/tutorial-extending-elixir-with-c-using-NIF/
- https://github.com/jeffkreeftmeijer/elixir-nif-examples/tree/master/c_src

## Dec 22, Rust NIF, but I still prefer C

- https://github.com/rusterlium/rustler
- https://blog.discordapp.com/using-rust-to-scale-elixir-for-11-million-concurrent-users-c6f19fc029d3
- https://medium.com/@jacob.lerche/writing-rust-nifs-for-your-elixir-code-with-the-rustler-package-d884a7c0dbe3 

## Dec 22, reference LAPACK

- https://github.com/Reference-LAPACK/lapack
- according to [wiki](https://en.wikipedia.org/wiki/NumPy) : both MATLAB and NumPy
  rely on BLAS and LAPACK for efficient linear algebra computations.
- https://markus-beuckelmann.de/blog/boosting-numpy-blas.html

## Dec 21, Lock dependency versions

[Best practices for deploying Elixir apps](
https://www.cogini.com/blog/best-practices-for-deploying-elixir-apps/)

Mix records the specific versions that it fetched in the `mix.lock` file.
Check the `mix.lock` file into source control.
Later, on the build machine, mix will use the specific package version,
the same as during development and testing.

## Dec 20, `mix compile` also executes `ping_alphavantage`

[Elixir always compiles and always executes source code.](
https://medium.com/@fxn/how-does-elixir-compile-execute-code-c1b36c9ec8cf)

## Dec 20, Install ElixirLS extention for VS Code

- Automatic, incremental Dialyzer analysis (requires Erlang OTP 20)
- Automatic suggestion for @spec annotations based on Dialyzer's inferred success typings

## Dec 20 2019, Set up ExDoc

- https://elixirschool.com/en/lessons/basics/documentation/#installing

```elixir
def deps do
  [{:earmark, "~> 1.2", only: :dev},
  {:ex_doc, "~> 0.19", only: :dev}]
end
```

- https://elixirschool.com/en/lessons/basics/documentation/#generating-documentation

```teminal
$ mix deps.get
Could not find Hex, which is needed to build dependency :earmark
Shall I install Hex? (if running non-interactively, use "mix local.hex --force") [Yn] y
* creating /home/igor/.asdf/installs/elixir/1.9.4-otp-20/.mix/archives/hex-0.20.1
Resolving Hex dependencies...
Dependency resolution completed:
New:
  earmark 1.4.3
  ex_doc 0.21.2
  makeup 1.0.0
  makeup_elixir 0.14.0
  nimble_parsec 0.5.3
* Getting earmark (Hex package)
* Getting ex_doc (Hex package)
* Getting makeup_elixir (Hex package)
* Getting makeup (Hex package)
* Getting nimble_parsec (Hex package)

ls deps/
earmark  ex_doc  makeup  makeup_elixir  nimble_parsec
```

```terminal
$ mix docs # makes the documentation.
```

- check [best practice](https://elixirschool.com/en/lessons/basics/documentation/#best-practice)
- [mix docs](https://hexdocs.pm/ex_doc/Mix.Tasks.Docs.html)

- change docs output directory, I found the field in [ExDoc source code](https://github.com/elixir-lang/ex_doc/blob/master/lib/ex_doc/config.ex)

```elixir
defmodule Gex.MixProject do
  use Mix.Project

  def project do
    [

      # Docs
      docs: [
        output: "../doc"
      ]
    ]
  end
```


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
