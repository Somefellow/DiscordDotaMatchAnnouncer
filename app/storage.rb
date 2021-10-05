# frozen_string_literal: true

require 'json'

class Storage
  def initialize(storage_file)
    @storage_file = storage_file
  end

  def generate_file
    return if File.exist?(@storage_file)

    data_hash = {
      'config' => { 'webhook_url' => '',
                    'error_webhook_url' => '',
                    'steam_api_key' => '',
                    'log_dir' => './logs' },
      'data' => {}
    }
    File.write(@storage_file, JSON.pretty_generate(data_hash))
  end

  def track_player(player_id, match_id, steam_id)
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)
    data_hash['data'][player_id] = { 'match_id' => match_id, 'steam_id' => steam_id }
    File.write(@storage_file, JSON.pretty_generate(data_hash))
  end

  def get_webhook_url
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)

    data_hash['config']['webhook_url']
  end

  def get_error_webhook_url
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)

    data_hash['config']['error_webhook_url']
  end

  def get_steam_api_key
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)

    data_hash['config']['steam_api_key']
  end

  def get_log_dir
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)

    data_hash['config']['log_dir']
  end

  def get_player_list
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)

    data_hash['data'].keys
  end

  def get_match_id(player_id)
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)

    data_hash['data'][player_id]['match_id']
  end

  def set_match_id(player_id, match_id)
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)
    data_hash['data'][player_id]['match_id'] = match_id
    File.write(@storage_file, JSON.pretty_generate(data_hash))
  end

  def get_display_name(player_id)
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)

    data_hash['data'][player_id]['display_name']
  end

  def set_display_name(player_id, display_name)
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)
    data_hash['data'][player_id]['display_name'] = display_name
    File.write(@storage_file, JSON.pretty_generate(data_hash))
  end

  def get_steam_id(player_id)
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)

    data_hash['data'][player_id]['steam_id']
  end

  def set_steam_id(player_id, steam_id)
    file = File.read(@storage_file)
    data_hash = JSON.parse(file)
    data_hash['data'][player_id]['steam_id'] = steam_id
    File.write(@storage_file, JSON.pretty_generate(data_hash))
  end
end
