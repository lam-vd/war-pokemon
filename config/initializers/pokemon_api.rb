# frozen_string_literal: true

# Load Pokemon API Configuration during initialization
Rails.application.config.to_prepare do
  require Rails.root.join('config', 'pokemon_api') unless defined?(PokemonApiConfig)
end
