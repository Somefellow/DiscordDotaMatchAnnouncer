# frozen_string_literal: true

require 'json'

class Constants
  def initialize(constant_file)
    @constant_file = constant_file
  end

  def get_game_mode(game_mode_id)
    file = File.read(@constant_file)
    data_hash = JSON.parse(file)

    data_hash['game_mode'][game_mode_id]
  end

  def get_lobby_type(lobby_type_id)
    file = File.read(@constant_file)
    data_hash = JSON.parse(file)

    data_hash['lobby_type'][lobby_type_id]
  end
end
