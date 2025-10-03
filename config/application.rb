require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WarPokemon
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    config.time_zone = "Asia/Ho_Chi_Minh"
    
    # Pokemon API Configuration
    config.pokemon_api = ActiveSupport::OrderedOptions.new
    config.pokemon_api.base_url = ENV.fetch('POKEMON_API_BASE_URL', 'https://pokeapi.co/api/v2')
    config.pokemon_api.timeout = ENV.fetch('POKEMON_API_TIMEOUT', 10).to_i
    config.pokemon_api.cache_duration = ENV.fetch('POKEMON_CACHE_DURATION', 3600).to_i
    config.pokemon_api.rate_limit = ENV.fetch('POKEMON_API_RATE_LIMIT', 100).to_i
    config.pokemon_api.max_retries = ENV.fetch('POKEMON_API_MAX_RETRIES', 3).to_i
    
    # App Configuration
    config.app_name = ENV.fetch('APP_NAME', 'War Pokemon')
    config.items_per_page = ENV.fetch('ITEMS_PER_PAGE', 20).to_i
    config.version = '1.0.0'
    
    # Redis Configuration
    config.redis_url = ENV.fetch('REDIS_URL', 'redis://redis:6379/0')
    
    # Auto-load services only (remove config from autoload)
    config.autoload_paths += %W(#{config.root}/app/services)
  end
end