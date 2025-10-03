class BattlesController < ApplicationController
  before_action :set_pokemon_service

  def new
    # Chọn Pokemon để battle
    @pokemon_id = params[:pokemon_id] || 25 # Default Pikachu
    @pokemon = @pokemon_service.find_pokemon(@pokemon_id)
    
    # If there's an error, use default Pikachu
    if @pokemon[:error]
      Rails.logger.error "Battle new error: #{@pokemon[:error]}"
      @pokemon = @pokemon_service.find_pokemon('25') # Default to Pikachu
    end
  end

  def create
    player_pokemon_id = params[:player_pokemon_id]
    opponent_pokemon_id = rand(1..151) # Random Gen 1 Pokemon
    
    # Get player Pokemon
    @player_pokemon = @pokemon_service.find_pokemon(player_pokemon_id)
    if @player_pokemon[:error]
      return render json: { 
        success: false, 
        error: "Không thể tìm thấy Pokemon của bạn: #{@player_pokemon[:error]}" 
      }
    end
    
    # Get opponent Pokemon - try multiple times if needed
    @opponent_pokemon = nil
    max_attempts = 5
    attempt = 0
    
    while @opponent_pokemon.nil? && attempt < max_attempts
      attempt += 1
      opponent_result = @pokemon_service.find_pokemon(rand(1..151))
      
      unless opponent_result[:error]
        @opponent_pokemon = opponent_result
      end
    end
    
    # If still no opponent, use fallback
    if @opponent_pokemon.nil?
      fallback_opponents = [25, 6, 1, 150, 7, 133] # Popular Pokemon
      @opponent_pokemon = @pokemon_service.find_pokemon(fallback_opponents.sample)
    end
    
    if @opponent_pokemon[:error]
      return render json: { 
        success: false, 
        error: "Không thể tìm đối thủ. Vui lòng thử lại!" 
      }
    end
    
    # Simulate battle
    @battle_log = simulate_battle(@player_pokemon, @opponent_pokemon)
    
    render json: {
      success: true,
      player_pokemon: @player_pokemon,
      opponent_pokemon: @opponent_pokemon,
      battle_log: @battle_log
    }
  end

  private

  def set_pokemon_service
    @pokemon_service = PokemonServiceV2.new
  end

  def simulate_battle(player, opponent)
    battle_log = []
    player_hp = calculate_hp(player[:stats]['HP'] || 100)
    opponent_hp = calculate_hp(opponent[:stats]['HP'] || 100)
    
    max_player_hp = player_hp
    max_opponent_hp = opponent_hp
    
    turn = 1
    battle_log << "⚔️ Trận đấu bắt đầu!"
    battle_log << "🔥 #{player[:name]} (HP: #{player_hp}) vs #{opponent[:name]} (HP: #{opponent_hp})"
    battle_log << "---"
    
    # Determine who goes first based on Speed
    player_speed = player[:stats]['Speed'] || 50
    opponent_speed = opponent[:stats]['Speed'] || 50
    
    player_first = player_speed >= opponent_speed
    battle_log << "⚡ #{player_first ? player[:name] : opponent[:name]} đi trước (Speed: #{player_first ? player_speed : opponent_speed})"
    battle_log << ""
    
    while player_hp > 0 && opponent_hp > 0 && turn <= 10 # Max 10 turns
      battle_log << "🔸 Turn #{turn}:"
      
      if player_first
        # Player attacks first
        if player_hp > 0
          damage = calculate_damage(player, opponent)
          opponent_hp -= damage
          opponent_hp = [opponent_hp, 0].max
          
          battle_log << "⚡ #{player[:name]} tấn công #{opponent[:name]} gây #{damage} damage!"
          battle_log << "💚 #{opponent[:name]} HP: #{opponent_hp}/#{max_opponent_hp}"
          
          break if opponent_hp <= 0
        end
        
        # Opponent attacks second
        if opponent_hp > 0
          damage = calculate_damage(opponent, player)
          player_hp -= damage
          player_hp = [player_hp, 0].max
          
          battle_log << "💥 #{opponent[:name]} phản đòn #{player[:name]} gây #{damage} damage!"
          battle_log << "❤️ #{player[:name]} HP: #{player_hp}/#{max_player_hp}"
        end
      else
        # Opponent attacks first
        if opponent_hp > 0
          damage = calculate_damage(opponent, player)
          player_hp -= damage
          player_hp = [player_hp, 0].max
          
          battle_log << "💥 #{opponent[:name]} tấn công #{player[:name]} gây #{damage} damage!"
          battle_log << "❤️ #{player[:name]} HP: #{player_hp}/#{max_player_hp}"
          
          break if player_hp <= 0
        end
        
        # Player attacks second
        if player_hp > 0
          damage = calculate_damage(player, opponent)
          opponent_hp -= damage
          opponent_hp = [opponent_hp, 0].max
          
          battle_log << "⚡ #{player[:name]} phản đòn #{opponent[:name]} gây #{damage} damage!"
          battle_log << "💚 #{opponent[:name]} HP: #{opponent_hp}/#{max_opponent_hp}"
        end
      end
      
      battle_log << ""
      turn += 1
    end
    
    # Determine winner
    if player_hp > opponent_hp
      battle_log << "🏆 #{player[:name]} thắng!"
      battle_log << "🎉 Chúc mừng! Bạn đã chiến thắng!"
    elsif opponent_hp > player_hp  
      battle_log << "😢 #{opponent[:name]} thắng!"
      battle_log << "💪 Đừng bỏ cuộc! Thử lại lần nữa!"
    else
      battle_log << "🤝 Hòa!"
      battle_log << "⚖️ Trận đấu kết thúc với tỷ số hòa!"
    end
    
    {
      log: battle_log,
      winner: player_hp > opponent_hp ? 'player' : (opponent_hp > player_hp ? 'opponent' : 'tie'),
      final_player_hp: player_hp,
      final_opponent_hp: opponent_hp,
      max_player_hp: max_player_hp,
      max_opponent_hp: max_opponent_hp
    }
  end
  
  def calculate_hp(base_hp)
    # Convert base stat to battle HP (similar to Pokemon games)
    ((2 * base_hp + 100) * 50 / 100 + 10).round
  end
  
  def calculate_damage(attacker, defender)
    # Simplified damage calculation based on Pokemon formula
    attack = attacker[:stats]['Attack'] || 50
    defense = defender[:stats]['Defense'] || 50
    
    # Base damage calculation
    base_damage = ((2 * 50 + 10) / 250.0) * (attack / defense.to_f) * 50 + 2
    
    # Add some randomness (85-100% of base damage)
    multiplier = rand(85..100) / 100.0
    
    # Critical hit chance (1/16)
    critical = rand(1..16) == 1
    if critical
      base_damage *= 1.5
    end
    
    final_damage = (base_damage * multiplier).round
    
    # Ensure minimum damage of 1
    [final_damage, 1].max
  end
end
