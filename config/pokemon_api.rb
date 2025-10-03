# frozen_string_literal: true

# Pokemon API Configuration
class PokemonApiConfig
  BASE_URL = ENV.fetch('POKEMON_API_BASE_URL', 'https://pokeapi.co/api/v2').freeze
  
  # API Endpoints
  ENDPOINTS = {
    pokemon: '/pokemon',
    species: '/pokemon-species',
    type: '/type',
    ability: '/ability',
    move: '/move',
    evolution_chain: '/evolution-chain',
    generation: '/generation',
    pokedex: '/pokedex'
  }.freeze
  
  # API Settings
  TIMEOUT = ENV.fetch('POKEMON_API_TIMEOUT', 10).to_i
  RATE_LIMIT = ENV.fetch('POKEMON_API_RATE_LIMIT', 100).to_i # requests per minute
  CACHE_DURATION = ENV.fetch('POKEMON_CACHE_DURATION', 3600).to_i # 1 hour
  MAX_RETRIES = ENV.fetch('POKEMON_API_MAX_RETRIES', 3).to_i
  
  # URL Builders
  def self.pokemon_url(id_or_name)
    "#{BASE_URL}#{ENDPOINTS[:pokemon]}/#{id_or_name.to_s.downcase}"
  end
  
  def self.species_url(id_or_name)
    "#{BASE_URL}#{ENDPOINTS[:species]}/#{id_or_name.to_s.downcase}"
  end
  
  def self.type_url(id_or_name)
    "#{BASE_URL}#{ENDPOINTS[:type]}/#{id_or_name.to_s.downcase}"
  end
  
  def self.ability_url(id_or_name)
    "#{BASE_URL}#{ENDPOINTS[:ability]}/#{id_or_name.to_s.downcase}"
  end
  
  def self.move_url(id_or_name)
    "#{BASE_URL}#{ENDPOINTS[:move]}/#{id_or_name.to_s.downcase}"
  end
  
  def self.evolution_chain_url(id)
    "#{BASE_URL}#{ENDPOINTS[:evolution_chain]}/#{id}"
  end
  
  def self.generation_url(id)
    "#{BASE_URL}#{ENDPOINTS[:generation]}/#{id}"
  end
  
  # Paginated endpoints
  def self.pokemon_list_url(limit: 20, offset: 0)
    "#{BASE_URL}#{ENDPOINTS[:pokemon]}?limit=#{limit}&offset=#{offset}"
  end
  
  def self.type_list_url(limit: 20, offset: 0)
    "#{BASE_URL}#{ENDPOINTS[:type]}?limit=#{limit}&offset=#{offset}"
  end
end
