# app/services/pokemon_service_v2.rb
class PokemonServiceV2 < BaseService
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

  def self.get_pokemon_list(limit = 20, offset = 0)
    new.get_pokemon_list(limit, offset)
  end

  def find_pokemon(pokemon_identifier)
    # Normalize input - remove spaces, convert to lowercase
    identifier = pokemon_identifier.to_s.strip.downcase

    return { error: "Pokemon name or ID is required" } if identifier.blank?

    # Use poke-api-v2 gem - try multiple times before fallback
    begin
      Rails.logger.info "Attempting to fetch Pokemon: #{identifier}"
      
      # Try with gem first
      pokemon = PokeApi.get(pokemon: identifier)
      
      if pokemon && pokemon.respond_to?(:id)
        Rails.logger.info "Successfully fetched #{pokemon.name} from API"
        return format_pokemon_data(pokemon)
      else
        Rails.logger.warn "Pokemon data invalid or empty for: #{identifier}"
      end
      
    rescue StandardError => e
      if e.message.include?("404") || e.message.include?("Not Found") || e.message.include?("not found")
        Rails.logger.warn "Pokemon not found: #{identifier} - #{e.message}"
        return { error: "Pokémon '#{identifier}' not found" }
      end
      
    rescue => e
      Rails.logger.error "PokemonService API Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # Only fallback for network/connection errors
      if e.message.include?("connection") || e.message.include?("timeout") || e.message.include?("resolve")
        Rails.logger.info "Network issue detected, using fallback data for: #{identifier}"
        return get_offline_pokemon_data(identifier)
      else
        return { error: "Unable to fetch Pokémon data: #{e.message}" }
      end
    end

    # Should not reach here normally
    { error: "Unexpected error occurred while fetching Pokemon" }
  end

  def search_pokemon(query)
    return [] if query.blank?

    # Use real API search - try to get the Pokemon directly
    result = find_pokemon(query)
    
    if result && !result[:error]
      return [{ name: result[:name], id: result[:id] }]
    else
      # If exact match fails, try some common variations
      variations = generate_search_variations(query)
      results = []
      
      variations.each do |variant|
        pokemon_result = find_pokemon(variant)
        if pokemon_result && !pokemon_result[:error]
          results << { name: pokemon_result[:name], id: pokemon_result[:id] }
          break # Found one, that's enough
        end
      end
      
      return results.uniq { |r| r[:id] }
    end
  end

  def random_pokemon
    # Try random API call with multiple attempts
    max_attempts = 5
    attempt = 0
    
    while attempt < max_attempts
      begin
        # Generate random ID - focus on Gen 1-8 for better success rate
        random_id = rand(1..898) # Up to Gen 8
        
        Rails.logger.info "Attempting to fetch random Pokemon ID: #{random_id} (attempt #{attempt + 1})"
        
        pokemon = PokeApi.get(pokemon: random_id)
        
        if pokemon && pokemon.respond_to?(:id)
          Rails.logger.info "Successfully fetched random Pokemon: #{pokemon.name}"
          return format_pokemon_data(pokemon)
        end
        
      rescue StandardError => e
        if e.message.include?("404") || e.message.include?("Not Found") || e.message.include?("not found")
          Rails.logger.info "Pokemon ID #{random_id} not found, trying another..."
        else
          Rails.logger.warn "Error fetching random Pokemon (attempt #{attempt + 1}): #{e.message}"
        end
      end
      
      attempt += 1
    end

    # Only after multiple failed attempts, use fallback
    Rails.logger.warn "All random attempts failed, using fallback data"
    demo_ids = ['25', '6', '1', '150', '7', '133']
    get_offline_pokemon_data(demo_ids.sample)
  end

  def get_pokemon_list(limit = 20, offset = 0)
    begin
      Rails.logger.info "Fetching Pokemon list: limit=#{limit}, offset=#{offset}"
      
      # Try to use real API data
      fetch_pokemon_list_from_api(limit, offset)
      
    rescue => e
      Rails.logger.error "Error fetching Pokemon list: #{e.message}"
      # Only fallback to limited data when API fails
      get_fallback_pokemon_list(limit, offset)
    end
  end

  private

  def generate_search_variations(query)
    variations = []
    clean_query = query.to_s.strip.downcase
    
    # Original query
    variations << clean_query
    
    # Remove common prefixes/suffixes
    variations << clean_query.gsub(/^(mr\.?|dr\.?|mt\.?)\s*/, '')
    variations << clean_query.gsub(/\s*(jr\.?|sr\.?)$/, '')
    
    # Handle common misspellings or variations
    case clean_query
    when /pika/
      variations << 'pikachu'
    when /char/
      variations << 'charizard'
    when /bulb/
      variations << 'bulbasaur'
    when /squir/
      variations << 'squirtle'
    end
    
    variations.uniq
  end

  def format_pokemon_data(pokemon)
    begin
      # Get species data for more detailed info
      species_data = get_pokemon_species_data(pokemon.id)
      
      {
        id: pokemon.id,
        name: pokemon.name.titleize,
        height: pokemon.height,
        weight: pokemon.weight,
        types: extract_types_from_api(pokemon.types),
        stats: extract_stats_from_api(pokemon.stats),
        sprites: extract_sprites_from_api(pokemon.sprites),
        abilities: extract_abilities_from_api(pokemon.abilities),
        description: species_data[:description] || get_pokemon_description(pokemon.id),
        generation: species_data[:generation] || "Generation #{get_generation_number(pokemon.id)}",
        habitat: species_data[:habitat] || get_pokemon_habitat(pokemon.id)
      }
    rescue => e
      Rails.logger.warn "Error formatting Pokemon data: #{e.message}"
      # Fallback to basic formatting
      {
        id: pokemon.id,
        name: pokemon.name.titleize,
        height: pokemon.height,
        weight: pokemon.weight,
        types: extract_types_from_api(pokemon.types),
        stats: extract_stats_from_api(pokemon.stats),
        sprites: extract_sprites_from_api(pokemon.sprites),
        abilities: extract_abilities_from_api(pokemon.abilities),
        description: get_pokemon_description(pokemon.id),
        generation: "Generation #{get_generation_number(pokemon.id)}",
        habitat: get_pokemon_habitat(pokemon.id)
      }
    end
  end

  def extract_types_from_api(types)
    return [] unless types&.any?

    types.map do |type_info|
      type_name = type_info.type.name
      {
        name: type_name.titleize,
        color: TYPES[type_name.to_sym] || '#68a090'
      }
    end
  end

  def extract_stats_from_api(stats)
    return {} unless stats&.any?

    result = {}
    stats.each do |stat_info|
      stat_name = stat_info.stat.name
      base_stat = stat_info.base_stat
      
      # Convert API stat names to readable names
      readable_name = case stat_name
                     when 'hp' then 'HP'
                     when 'attack' then 'Attack'
                     when 'defense' then 'Defense'
                     when 'special-attack' then 'Sp. Attack'
                     when 'special-defense' then 'Sp. Defense'
                     when 'speed' then 'Speed'
                     else stat_name.titleize
                     end

      result[readable_name] = base_stat if readable_name
    end

    # Calculate total stats
    result['Total'] = result.values.sum if result.any?
    result
  end

  def extract_sprites_from_api(sprites)
    return {} unless sprites

    # Handle different sprite structures from poke-api-v2 gem
    result = {
      front_default: sprites.front_default,
      front_shiny: sprites.front_shiny,
      back_default: sprites.back_default
    }

    # Try to get official artwork - different approaches for different structures
    if sprites.respond_to?(:other) && sprites.other
      result[:official_artwork] = sprites.other.dig('official-artwork', 'front_default')
    elsif sprites.respond_to?(:front_default) && sprites.front_default
      # For poke-api-v2 gem, construct official artwork URL from sprite ID
      pokemon_id = extract_pokemon_id_from_sprite_url(sprites.front_default)
      if pokemon_id
        result[:official_artwork] = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/#{pokemon_id}.png"
      end
    end

    result.compact
  end

  def extract_abilities_from_api(abilities)
    return [] unless abilities&.any?

    abilities.map do |ability_info|
      ability_info.ability.name.titleize
    end
  end

  def get_pokemon_description(pokemon_id)
    case pokemon_id
    when 25
      "When Pikachu meets with other Pikachu, it will touch tails and exchange electricity through them as a form of greeting."
    when 6
      "Charizard flies around the sky in search of powerful opponents. It breathes fire of such great heat that it melts anything."
    when 1
      "Bulbasaur can be seen napping in bright sunlight. There is a seed on its back."
    when 150
      "Mewtwo is a Pokémon that was created by genetic manipulation."
    else
      "A wonderful Pokemon with unique characteristics."
    end
  end

  def get_generation_number(pokemon_id)
    case pokemon_id
    when 1..151 then "I"
    when 152..251 then "II"  
    when 252..386 then "III"
    when 387..493 then "IV"
    when 494..649 then "V"
    when 650..721 then "VI"
    when 722..809 then "VII"
    when 810..905 then "VIII"
    else "IX"
    end
  end

  def get_pokemon_habitat(pokemon_id)
    case pokemon_id
    when 25 then "Forest"
    when 6 then "Mountain"  
    when 1 then "Grassland"
    when 150 then "Rare"
    else "Unknown"
    end
  end

  def get_pokemon_species_data(pokemon_id)
    begin
      species = PokeApi.get(pokemon_species: pokemon_id)
      
      if species
        # Extract English description
        description = extract_english_description(species.flavor_text_entries)
        
        # Extract generation info
        generation = species.generation&.name&.gsub('generation-', 'Generation ')&.upcase || nil
        
        # Extract habitat
        habitat = species.habitat&.name&.titleize || nil
        
        {
          description: description,
          generation: generation,
          habitat: habitat
        }
      else
        {}
      end
    rescue => e
      Rails.logger.info "Could not fetch species data for Pokemon #{pokemon_id}: #{e.message}"
      {}
    end
  end

  def extract_english_description(flavor_text_entries)
    return nil unless flavor_text_entries&.any?
    
    # Find English flavor text
    english_entry = flavor_text_entries.find do |entry|
      entry.language&.name == 'en'
    end
    
    if english_entry&.flavor_text
      # Clean up the text
      english_entry.flavor_text.gsub(/\n|\f|\r/, ' ').squeeze(' ').strip
    else
      nil
    end
  end

  def extract_pokemon_id_from_sprite_url(sprite_url)
    return nil unless sprite_url
    
    # Extract ID from URL like: https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png
    match = sprite_url.match(%r{/sprites/pokemon/(\d+)\.png})
    match ? match[1] : nil
  end

  def extract_id_from_url(url)
    return nil unless url
    
    # Extract ID from URL like: https://pokeapi.co/api/v2/pokemon/1/
    match = url.match(%r{/pokemon/(\d+)/?$})
    match ? match[1].to_i : nil
  end

  def fetch_pokemon_list_from_api(limit, offset)
    require 'net/http'
    require 'json'
    
    # Try cache first (simple memory cache for demo)
    cache_key = "pokemon_list_#{limit}_#{offset}"
    
    uri = URI("https://pokeapi.co/api/v2/pokemon/?limit=#{limit}&offset=#{offset}")
    
    Rails.logger.info "Making direct HTTP request to: #{uri}"
    
    # Set timeout for the HTTP request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 15
    
    response = http.get(uri.path + "?" + uri.query.to_s)
    
    if response.code == '200'
      data = JSON.parse(response.body)
      
      results = data['results'].map do |pokemon|
        # Extract ID from URL
        id = extract_id_from_url(pokemon['url'])
        {
          name: pokemon['name'].titleize,
          id: id,
          url: pokemon['url']
        }
      end
      
      Rails.logger.info "Successfully fetched #{results.length} Pokemon from PokeAPI.co"
      
      {
        results: results,
        count: data['count'],
        next: data['next'],
        previous: data['previous'],
        source: 'PokeAPI.co'
      }
    else
      Rails.logger.error "PokeAPI request failed with code: #{response.code}"
      raise "API request failed: #{response.code} - #{response.body}"
    end
  end

  def get_fallback_pokemon_list(limit, offset)
    Rails.logger.warn "Using fallback Pokemon list - API unavailable"
    
    # Generate Pokemon list dynamically based on pagination
    # This gives us up to 1000+ Pokemon instead of hardcoded list
    total_pokemon = 1010 # Current total Pokemon in PokeAPI
    
    results = []
    start_id = offset + 1
    end_id = [offset + limit, total_pokemon].min
    
    (start_id..end_id).each do |id|
      results << {
        name: get_pokemon_name_by_id(id),
        id: id,
        url: "https://pokeapi.co/api/v2/pokemon/#{id}/"
      }
    end
    
    {
      results: results,
      count: total_pokemon,
      next: (offset + limit < total_pokemon) ? "next_page" : nil,
      previous: (offset > 0) ? "previous_page" : nil
    }
  end

  def get_pokemon_name_by_id(id)
    # For fallback, try to fetch individual Pokemon name from gem/API
    # If that fails, use generic name
    begin
      pokemon = PokeApi.get(pokemon: id)
      pokemon&.name&.titleize || "Pokemon #{id}"
    rescue
      "Pokemon #{id}"
    end
  end

  def get_offline_pokemon_data(identifier)
    Rails.logger.info "Using offline fallback data for: #{identifier}"
    
    # Match by name or ID - limited fallback for network issues only
    case identifier.to_s.downcase
    when 'pikachu', '25'
      {
        id: 25,
        name: 'Pikachu',
        height: 4,
        weight: 60,
        types: [{ name: 'Electric', color: '#F8D030' }],
        stats: {
          'HP' => 35,
          'Attack' => 55,
          'Defense' => 40,
          'Sp. Attack' => 50,
          'Sp. Defense' => 50,
          'Speed' => 90,
          'Total' => 320
        },
        sprites: {
          front_default: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png',
          official_artwork: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png'
        },
        abilities: ['Static', 'Lightning Rod'],
        description: "When Pikachu meets with other Pikachu, it will touch tails and exchange electricity through them as a form of greeting.",
        generation: "Generation I",
        habitat: "Forest"
      }
    when 'charizard', '6'
      {
        id: 6,
        name: 'Charizard',
        height: 17,
        weight: 905,
        types: [{ name: 'Fire', color: '#F08030' }, { name: 'Flying', color: '#A890F0' }],
        stats: {
          'HP' => 78,
          'Attack' => 84,
          'Defense' => 78,
          'Sp. Attack' => 109,
          'Sp. Defense' => 85,
          'Speed' => 100,
          'Total' => 534
        },
        sprites: {
          front_default: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/6.png',
          official_artwork: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png'
        },
        abilities: ['Blaze', 'Solar Power'],
        description: "Charizard flies around the sky in search of powerful opponents. It breathes fire of such great heat that it melts anything.",
        generation: "Generation I",
        habitat: "Mountain"
      }
    when 'bulbasaur', '1'
      {
        id: 1,
        name: 'Bulbasaur',
        height: 7,
        weight: 69,
        types: [{ name: 'Grass', color: '#78C850' }, { name: 'Poison', color: '#A040A0' }],
        stats: {
          'HP' => 45,
          'Attack' => 49,
          'Defense' => 49,
          'Sp. Attack' => 65,
          'Sp. Defense' => 65,
          'Speed' => 45,
          'Total' => 318
        },
        sprites: {
          front_default: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
          official_artwork: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png'
        },
        abilities: ['Overgrow', 'Chlorophyll'],
        description: "Bulbasaur can be seen napping in bright sunlight. There is a seed on its back.",
        generation: "Generation I",
        habitat: "Grassland"
      }
    when 'mewtwo', '150'
      {
        id: 150,
        name: 'Mewtwo',
        height: 20,
        weight: 1220,
        types: [{ name: 'Psychic', color: '#F85888' }],
        stats: {
          'HP' => 106,
          'Attack' => 110,
          'Defense' => 90,
          'Sp. Attack' => 154,
          'Sp. Defense' => 90,
          'Speed' => 130,
          'Total' => 680
        },
        sprites: {
          front_default: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/150.png',
          official_artwork: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/150.png'
        },
        abilities: ['Pressure', 'Unnerve'],
        description: "Mewtwo is a Pokémon that was created by genetic manipulation. However, even though the scientific power of humans created this Pokémon's body, they failed to endow Mewtwo with a compassionate heart.",
        generation: "Generation I",
        habitat: "Rare"
      }
    when 'squirtle', '7'
      {
        id: 7,
        name: 'Squirtle',
        height: 5,
        weight: 90,
        types: [{ name: 'Water', color: '#6890F0' }],
        stats: {
          'HP' => 44,
          'Attack' => 48,
          'Defense' => 65,
          'Sp. Attack' => 50,
          'Sp. Defense' => 64,
          'Speed' => 43,
          'Total' => 314
        },
        sprites: {
          front_default: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/7.png',
          official_artwork: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/7.png'
        },
        abilities: ['Torrent', 'Rain Dish'],
        description: "Squirtle's shell is not merely used for protection. The shell's rounded shape and the grooves on its surface help minimize resistance in water.",
        generation: "Generation I",
        habitat: "Water's-edge"
      }
    when 'eevee', '133'
      {
        id: 133,
        name: 'Eevee',
        height: 3,
        weight: 65,
        types: [{ name: 'Normal', color: '#A8A878' }],
        stats: {
          'HP' => 55,
          'Attack' => 55,
          'Defense' => 50,
          'Sp. Attack' => 45,
          'Sp. Defense' => 65,
          'Speed' => 55,
          'Total' => 325
        },
        sprites: {
          front_default: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/133.png',
          official_artwork: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/133.png'
        },
        abilities: ['Run Away', 'Adaptability'],
        description: "Eevee has an unstable genetic makeup that suddenly mutates due to the environment in which it lives. Radiation from various stones causes this Pokémon to evolve.",
        generation: "Generation I",
        habitat: "Urban"
      }
    else
      { error: "Pokémon '#{identifier}' not found. Try: pikachu, charizard, bulbasaur, mewtwo, squirtle, eevee" }
    end
  end
end
