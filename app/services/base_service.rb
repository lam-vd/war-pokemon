# frozen_string_literal: true

# Base Service Class for all Pokemon-related services
class BaseService
  # include PokemonConstants # Temporarily commented out
  
  # Service Pattern: Call method for easy usage
  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end
  
  # Include HTTParty for API requests
  include HTTParty
  
  # Set default headers and options
  headers 'User-Agent' => "War Pokemon App v1.0"
  default_timeout 30
  
  protected
  
  # Pokemon API configuration access
  def pokemon_api_config
    @pokemon_api_config ||= begin
      require Rails.root.join('config', 'pokemon_api') unless defined?(PokemonApiConfig)
      PokemonApiConfig
    end
  end
  
  # Cache key generator with environment namespace
  def cache_key(key)
    "war_pokemon:#{Rails.env}:#{key}"
  end
  
  # Cache wrapper with default expiration
  def cache_fetch(key, expires_in: PokemonApiConfig::CACHE_DURATION, &block)
    Rails.cache.fetch(cache_key(key), expires_in: expires_in, &block)
  end
  
  # HTTP request wrapper with error handling
  def safe_request(url, options = {})
    retries = 0
    begin
      response = self.class.get(url, options)
      handle_response(response)
    rescue Net::TimeoutError, Net::OpenTimeout => e
      retries += 1
      if retries <= PokemonApiConfig::MAX_RETRIES
        Rails.logger.warn "Pokemon API timeout, retrying... (#{retries}/#{PokemonApiConfig::MAX_RETRIES})"
        sleep(retries * 0.5) # Exponential backoff
        retry
      else
        Rails.logger.error "Pokemon API failed after #{PokemonApiConfig::MAX_RETRIES} retries: #{e.message}"
        raise ApiError.new("Pokemon API timeout")
      end
    rescue => e
      Rails.logger.error "Pokemon API error: #{e.message}"
      raise ApiError.new("Pokemon API error: #{e.message}")
    end
  end
  
  # Response handler
  def handle_response(response)
    case response.code
    when 200
      response.parsed_response
    when 404
      raise NotFoundError.new("Pokemon not found")
    when 429
      raise RateLimitError.new("Rate limit exceeded")
    when 500..599
      raise ServerError.new("Pokemon API server error")
    else
      raise ApiError.new("Unknown API error: #{response.code}")
    end
  end
  
  # Error Classes
  class ApiError < StandardError; end
  class NotFoundError < ApiError; end
  class RateLimitError < ApiError; end
  class ServerError < ApiError; end
end
