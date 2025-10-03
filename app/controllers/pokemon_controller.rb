# app/controllers/pokemon_controller.rb
class PokemonController < ApplicationController
  before_action :set_pokemon, only: [:show]

  # GET /
  # Home page with search functionality
  def index
    @pokemon = nil
    @search_query = params[:search]&.strip
    @error = nil

    # Handle search request
    if @search_query.present?
      result = PokemonServiceV2.find_pokemon(@search_query)
      
      if result[:error]
        @error = result[:error]
      else
        @pokemon = result
      end
    end

    # Get a random Pokemon for the "Random Pokemon" feature
    @random_suggestion = get_random_suggestion

    respond_to do |format|
      format.html
      format.json { render json: @pokemon || { error: @error } }
    end
  end

  # GET /pokemon/:id
  # Show specific Pokemon details
  def show
    if @pokemon && @pokemon[:error]
      flash[:error] = @pokemon[:error]
      redirect_to root_path
    elsif @pokemon
      respond_to do |format|
        format.html
        format.json { render json: @pokemon }
      end
    else
      flash[:error] = "Pokemon not found"
      redirect_to root_path
    end
  end

  # GET /pokemon/random
  # Get a random Pokemon (AJAX endpoint)
  def random
    @pokemon = PokemonServiceV2.random_pokemon
    
    respond_to do |format|
      format.json { render json: @pokemon }
      format.html { redirect_to pokemon_path(@pokemon[:id]) if @pokemon && !@pokemon[:error] }
    end
  end

  # GET /pokemon/search?q=query
  # Search for Pokemon by name (AJAX endpoint for autocomplete)
  def search
    query = params[:q]&.strip
    
    if query.present?
      # For autocomplete, we'll return popular Pokemon names that match
      suggestions = get_pokemon_suggestions(query)
      render json: { suggestions: suggestions }
    else
      render json: { suggestions: [] }
    end
  end

  # GET /pokemon/compare
  # Compare two Pokemon
  def compare
    @pokemon1 = nil
    @pokemon2 = nil
    @error = nil

    pokemon1_query = params[:pokemon1]&.strip
    pokemon2_query = params[:pokemon2]&.strip

    if pokemon1_query.present? && pokemon2_query.present?
      # Fetch both Pokemon
      result1 = PokemonServiceV2.find_pokemon(pokemon1_query)
      result2 = PokemonServiceV2.find_pokemon(pokemon2_query)

      if result1[:error]
        @error = "First Pokemon: #{result1[:error]}"
      elsif result2[:error]
        @error = "Second Pokemon: #{result2[:error]}"
      else
        @pokemon1 = result1
        @pokemon2 = result2
      end
    end

    respond_to do |format|
      format.html
      format.json do
        if @error
          render json: { error: @error }
        else
          render json: { pokemon1: @pokemon1, pokemon2: @pokemon2 }
        end
      end
    end
  end

  # GET /pokemon/all
  # Show all Pokemon available in the API
  def all
    @page = (params[:page] || 1).to_i
    @limit = 20 # Pokemon per page
    @offset = (@page - 1) * @limit

    begin
      # Get Pokemon list from API
      pokemon_list = PokemonServiceV2.get_pokemon_list(@limit, @offset)
      
      @pokemon_list = pokemon_list[:results] || []
      @total_count = pokemon_list[:count] || 0
      @total_pages = (@total_count.to_f / @limit).ceil
      @has_next = pokemon_list[:next].present?
      @has_previous = pokemon_list[:previous].present?
      
    rescue => e
      Rails.logger.error "Error fetching Pokemon list: #{e.message}"
      @pokemon_list = []
      @total_count = 0
      @total_pages = 1
      @error = "Unable to load Pokemon list. Please try again later."
    end

    respond_to do |format|
      format.html
      format.json { render json: { pokemon: @pokemon_list, total: @total_count, page: @page } }
    end
  end

  # GET /pokemon/types/:type
  # Show information about a specific Pokemon type
  def type_info
    type_name = params[:type]&.downcase
    
    if type_name && PokemonConstants::TYPES.key?(type_name.to_sym)
      type_data = {
        name: type_name.titleize,
        color: PokemonConstants::TYPES[type_name.to_sym],
        # You could extend this to fetch type effectiveness data from the API
      }
      
      respond_to do |format|
        format.json { render json: type_data }
        format.html { redirect_to root_path }
      end
    else
      respond_to do |format|
        format.json { render json: { error: "Type not found" } }
        format.html { redirect_to root_path }
      end
    end
  end

  private

  def set_pokemon
    pokemon_id = params[:id]
    @pokemon = PokemonServiceV2.find_pokemon(pokemon_id)
  end

  def get_random_suggestion
    # Cache a few popular Pokemon for quick suggestions
    popular_pokemon = ['pikachu', 'charizard', 'blastoise', 'venusaur', 'mewtwo', 'mew', 'lucario', 'garchomp']
    popular_pokemon.sample
  end

  def get_pokemon_suggestions(query)
    # This is a simple implementation. In a real app, you might want to
    # maintain a database of Pokemon names for better search functionality
    popular_matches = [
      'pikachu', 'charizard', 'blastoise', 'venusaur', 'alakazam', 
      'machamp', 'golem', 'gengar', 'dragonite', 'mewtwo', 'mew',
      'typhlosion', 'feraligatr', 'meganium', 'lugia', 'ho-oh',
      'blaziken', 'swampert', 'sceptile', 'rayquaza', 'kyogre', 'groudon',
      'garchomp', 'lucario', 'dialga', 'palkia', 'giratina', 'arceus',
      'serperior', 'emboar', 'samurott', 'reshiram', 'zekrom', 'kyurem',
      'greninja', 'talonflame', 'chesnaught', 'xerneas', 'yveltal',
      'decidueye', 'incineroar', 'primarina', 'lunala', 'solgaleo',
      'rillaboom', 'cinderace', 'inteleon', 'eternatus', 'zacian', 'zamazenta'
    ]

    # Filter matches based on query
    matches = popular_matches.select { |name| name.include?(query.downcase) }
    
    # Limit to 5 suggestions
    matches.take(5).map(&:titleize)
  end

  # Helper method for strong parameters if needed for forms
  def pokemon_params
    params.permit(:search, :pokemon1, :pokemon2, :id, :q, :type)
  end
end
