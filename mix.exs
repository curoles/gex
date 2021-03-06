defmodule Gex.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      build_path: "../_build",

      # Docs
      docs: [
        output: "../doc"
      ],

      releases: [
        prod: [
          include_executables_for: [:unix],
        ]
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [{:earmark,   "~> 1.2",  only: :dev},
     {:ex_doc,    "~> 0.19", only: :dev},
     {:httpoison, "~> 1.6"}
    ]
  end
end
