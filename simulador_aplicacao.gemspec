# frozen_string_literal: true

require_relative "lib/simulador_aplicacao/version"

Gem::Specification.new do |spec|
  spec.name = "simulador_aplicacao"
  spec.version = SimuladorAplicacao::VERSION
  spec.authors = ["vinifmatos"]
  spec.email = ["viniciusfreire4@gmail.com"]

  spec.summary = "Simulador de Aplicação Financeira"
  spec.description = "Essa gem faz uma simulação de uma aplicação financeira utilizando como índice o CDI, o SELIC ou o IPCA, para um montante inicial pelo periodo desejado."
  spec.homepage = "https://github.com/vinifmatos"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/vinifmatos/simulador_aplicacao"
  spec.metadata["changelog_uri"] = "https://github.com/vinifmatos/simulador_aplicacao/README.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = ["simulador_aplicacao"]
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "tty-prompt", "~> 0.23"
  spec.add_dependency "tty-table", "~> 0.12"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
