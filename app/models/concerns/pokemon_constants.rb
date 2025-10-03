# frozen_string_literal: true

# Pokemon Constants and Helper Methods
module PokemonConstants
  # Pokemon Types with hex colors for UI
  TYPES = {
    'normal' => { color: '#A8A878', text: 'Normal' },
    'fire' => { color: '#F08030', text: 'Fire' },
    'water' => { color: '#6890F0', text: 'Water' },
    'electric' => { color: '#F8D030', text: 'Electric' },
    'grass' => { color: '#78C850', text: 'Grass' },
    'ice' => { color: '#98D8D8', text: 'Ice' },
    'fighting' => { color: '#C03028', text: 'Fighting' },
    'poison' => { color: '#A040A0', text: 'Poison' },
    'ground' => { color: '#E0C068', text: 'Ground' },
    'flying' => { color: '#A890F0', text: 'Flying' },
    'psychic' => { color: '#F85888', text: 'Psychic' },
    'bug' => { color: '#A8B820', text: 'Bug' },
    'rock' => { color: '#B8A038', text: 'Rock' },
    'ghost' => { color: '#705898', text: 'Ghost' },
    'dragon' => { color: '#7038F8', text: 'Dragon' },
    'dark' => { color: '#705848', text: 'Dark' },
    'steel' => { color: '#B8B8D0', text: 'Steel' },
    'fairy' => { color: '#EE99AC', text: 'Fairy' }
  }.freeze
  
  # Pokemon Stats with display names
  STATS = {
    'hp' => 'HP',
    'attack' => 'Attack',
    'defense' => 'Defense',
    'special-attack' => 'Sp. Attack',
    'special-defense' => 'Sp. Defense',
    'speed' => 'Speed'
  }.freeze
  
  # Pokemon Generations with ID ranges
  GENERATIONS = {
    1 => { range: (1..151), name: 'Kanto', region: 'Kanto' },
    2 => { range: (152..251), name: 'Johto', region: 'Johto' },
    3 => { range: (252..386), name: 'Hoenn', region: 'Hoenn' },
    4 => { range: (387..493), name: 'Sinnoh', region: 'Sinnoh' },
    5 => { range: (494..649), name: 'Unova', region: 'Unova' },
    6 => { range: (650..721), name: 'Kalos', region: 'Kalos' },
    7 => { range: (722..809), name: 'Alola', region: 'Alola' },
    8 => { range: (810..905), name: 'Galar', region: 'Galar' }
  }.freeze
  
  # Helper Methods
  module_function
  
  def type_color(type_name)
    TYPES.dig(type_name&.downcase, :color) || '#68A090'
  end
  
  def type_text(type_name)
    TYPES.dig(type_name&.downcase, :text) || type_name&.capitalize
  end
  
  def stat_name(stat_key)
    STATS[stat_key&.downcase] || stat_key&.humanize
  end
  
  def generation_by_id(pokemon_id)
    return nil unless pokemon_id.is_a?(Integer)
    
    GENERATIONS.find { |_gen, data| data[:range].include?(pokemon_id) }
  end
  
  def generation_name(pokemon_id)
    gen_data = generation_by_id(pokemon_id)
    gen_data ? gen_data.last[:name] : 'Unknown'
  end
end
