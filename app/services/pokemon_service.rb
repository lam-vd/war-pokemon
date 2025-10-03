# app/services/pokemon_service.rb
class PokemonService < BaseService
  include HTTParty
  include PokemonConstants

  def self.find_pokemon(pokemon_identifier)
    new.find_pokemon(pokemon_identifier)
  end

  def self.search_pokemon(query)
    new.search_pokemon(query)
  end

  def self.random_pokemon
    new.random_pokemon
  end

  def find_pokemon(pokemon_identifier)
    # Normalize input - remove spaces, convert to lowercase
    identifier = pokemon_identifier.to_s.strip.downcase

    return { error: "Pokemon name or ID is required" } if identifier.blank?

    cache_key = "pokemon:#{identifier}"

    cache_fetch(cache_key, expires_in: 1.hour) do
      begin
        url = pokemon_api_config.pokemon_url(identifier)
        response = HTTParty.get(url, timeout: 10)

        if response.success?
          pokemon_data = parse_pokemon_data(response.parsed_response)
          species_data = fetch_species_data(pokemon_data[:id])
          
          pokemon_data.merge(species_data)
        else
          case response.code
          when 404
            { error: "Pokemon '#{pokemon_identifier}' not found" }
          else
            { error: "Failed to fetch Pokemon data: #{response.message}" }
          end
        end

      rescue Net::OpenTimeout, Timeout::Error
        { error: "Request timeout - please try again" }
      rescue => e
        Rails.logger.error "PokemonService Error: #{e.message}"
        { error: "An unexpected error occurred" }
      end
    end
  end

  def search_pokemon(query)
    return [] if query.blank?

    # This is a simple search - in production you might want to implement
    # a more sophisticated search with a Pokemon name database
    results = []
    
    # Try exact match first
    exact_match = find_pokemon(query)
    results << { name: query, id: exact_match[:id] } if exact_match && !exact_match[:error]

    # Try some common variations
    variations = [
      query.capitalize,
      query.upcase,
      query.gsub(/\s+/, '-')
    ]

    variations.each do |variation|
      next if variation == query
      
      result = find_pokemon(variation)
      if result && !result[:error]
        results << { name: variation, id: result[:id] }
        break if results.size >= 5 # Limit results
      end
    end

    results.uniq { |r| r[:id] }
  end

  def random_pokemon
    # Random Pokemon ID between 1-1010 (current total)
    random_id = rand(1..1010)
    find_pokemon(random_id)
  end

  private

  def parse_pokemon_data(data)
    {
      id: data['id'],
      name: data['name'].titleize,
      height: data['height'], # decimeters
      weight: data['weight'], # hectograms
      base_experience: data['base_experience'],
      types: extract_types(data['types']),
      stats: extract_stats(data['stats']),
      sprites: extract_sprites(data['sprites']),
      abilities: extract_abilities(data['abilities']),
      moves_count: data['moves']&.count || 0
    }
  end

  def fetch_species_data(pokemon_id)
    cache_key = "pokemon_species:#{pokemon_id}"
    
    cache_fetch(cache_key, expires_in: 1.hour) do
      begin
        url = pokemon_api_config.species_url(pokemon_id)
        response = HTTParty.get(url, timeout: 10)

        if response.success?
          species = response.parsed_response
          {
            generation: species.dig('generation', 'name')&.titleize,
            habitat: species.dig('habitat', 'name')&.titleize,
            color: species.dig('color', 'name')&.titleize,
            description: extract_description(species['flavor_text_entries']),
            evolution_chain_id: extract_evolution_chain_id(species['evolution_chain'])
          }
        else
          {
            generation: nil,
            habitat: nil,
            color: nil,
            description: "No description available",
            evolution_chain_id: nil
          }
        end
      rescue => e
        Rails.logger.error "Species fetch error: #{e.message}"
        {
          generation: nil,
          habitat: nil, 
          color: nil,
          description: "Description unavailable",
          evolution_chain_id: nil
        }
      end
    end
  end

  def extract_types(types_data)
    return [] unless types_data&.any?

    types_data.map do |type_info|
      type_name = type_info.dig('type', 'name')
      {
        name: type_name&.titleize,
        color: TYPES[type_name&.to_sym] || '#68a090'
      }
    end
  end

  def extract_stats(stats_data)
    return {} unless stats_data&.any?

    stats = {}
    stats_data.each do |stat_info|
      stat_name = stat_info.dig('stat', 'name')
      base_stat = stat_info['base_stat']
      
      # Convert API stat names to readable names
      readable_name = case stat_name
                     when 'hp' then 'HP'
                     when 'attack' then 'Attack'
                     when 'defense' then 'Defense'
                     when 'special-attack' then 'Sp. Attack'
                     when 'special-defense' then 'Sp. Defense'
                     when 'speed' then 'Speed'
                     else stat_name&.titleize
                     end

      stats[readable_name] = base_stat if readable_name
    end

    # Calculate total stats
    stats['Total'] = stats.values.sum if stats.any?
    stats
  end

  def extract_sprites(sprites_data)
    return {} unless sprites_data

    {
      front_default: sprites_data['front_default'],
      front_shiny: sprites_data['front_shiny'],
      back_default: sprites_data['back_default'],
      back_shiny: sprites_data['back_shiny'],
      official_artwork: sprites_data.dig('other', 'official-artwork', 'front_default'),
      home: sprites_data.dig('other', 'home', 'front_default'),
      dream_world: sprites_data.dig('other', 'dream_world', 'front_default')
    }.compact
  end

  def extract_abilities(abilities_data)
    return [] unless abilities_data&.any?

    abilities_data.map do |ability_info|
      {
        name: ability_info.dig('ability', 'name')&.titleize,
        is_hidden: ability_info['is_hidden'] || false
      }
    end
  end

  def extract_description(flavor_texts)
    return "No description available" unless flavor_texts&.any?

    # Try to find English description first
    english_entry = flavor_texts.find { |entry| entry['language']['name'] == 'en' }
    
    if english_entry
      # Clean up the description text
      description = english_entry['flavor_text']
      description.gsub(/[\n\f\r]/, ' ').squeeze(' ').strip
    else
      "No English description available"
    end
  end

  def extract_evolution_chain_id(evolution_chain_data)
    return nil unless evolution_chain_data&.dig('url')
    
    # Extract ID from URL like "https://pokeapi.co/api/v2/evolution-chain/1/"
    evolution_chain_data['url'][/\/(\d+)\/$/, 1]&.to_i
  end
end
