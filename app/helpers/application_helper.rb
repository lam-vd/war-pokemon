module ApplicationHelper
  # Helper method to compare stats and return appropriate CSS class
  def compare_stat_class(value1, value2)
    return '' if value2.nil?
    
    if value1 > value2
      'text-success'
    elsif value1 < value2
      'text-danger'
    else
      'text-muted'
    end
  end

  # Helper method for basic stat comparison (height, weight, experience)
  def compare_basic_stat_class(value1, value2)
    return '' if value2.nil?
    
    if value1 > value2
      'text-success'
    elsif value1 < value2
      'text-danger'
    else
      'text-muted'
    end
  end

  # Format Pokemon type with proper color
  def pokemon_type_badge(type_name, color)
    content_tag :span, type_name, 
                class: 'pokemon-type',
                style: "background-color: #{color}"
  end

  # Format stat with progress bar
  def stat_progress_bar(stat_value, max_value = 200)
    percentage = [stat_value.to_f / max_value * 100, 100].min
    
    content_tag :div, class: 'stat-bar' do
      content_tag :div, '', 
                  class: 'stat-fill',
                  style: "width: #{percentage}%"
    end
  end

  # Format Pokemon measurement (height/weight)
  def format_pokemon_measurement(value, unit, divisor = 10.0)
    "#{(value / divisor).round(1)} #{unit}"
  end

  # Get Pokemon image URL with fallback
  def pokemon_image_url(sprites, prefer_artwork = true)
    return sprites[:official_artwork] if prefer_artwork && sprites[:official_artwork].present?
    return sprites[:home] if sprites[:home].present?
    return sprites[:front_default] if sprites[:front_default].present?
    return sprites[:dream_world] if sprites[:dream_world].present?
    
    nil
  end

  # Check if Pokemon has image available
  def pokemon_has_image?(sprites)
    pokemon_image_url(sprites).present?
  end

  # Generate share text for Pokemon
  def pokemon_share_text(pokemon)
    "Check out #{pokemon[:name]} (##{pokemon[:id]}) on War Pokemon! " \
    "Height: #{format_pokemon_measurement(pokemon[:height], 'm')} | " \
    "Weight: #{format_pokemon_measurement(pokemon[:weight], 'kg')}"
  end

  # Format Pokemon stats for display
  def format_stat_name(api_stat_name)
    case api_stat_name.to_s
    when 'hp' then 'HP'
    when 'attack' then 'Attack'
    when 'defense' then 'Defense'
    when 'special-attack' then 'Sp. Attack'
    when 'special-defense' then 'Sp. Defense'
    when 'speed' then 'Speed'
    else
      api_stat_name.to_s.titleize
    end
  end

  # Get stat color based on value
  def stat_color_class(stat_value)
    case stat_value
    when 0..49 then 'text-danger'
    when 50..79 then 'text-warning'
    when 80..109 then 'text-info'
    when 110..139 then 'text-success'
    else 'text-purple fw-bold'
    end
  end

  # Format generation name
  def format_generation(generation_name)
    return '' if generation_name.blank?
    
    generation_name.gsub('generation-', 'Generation ').titleize
  end
end
