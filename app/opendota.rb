# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

class OpenDota
  def initialize
    @hero_cache = nil
    @player_data_cache = {}
    @rate_limit_remaining = 50_000 # x-rate-limit-remaining-month
  end

  def get_rate_limit_remaining
    @rate_limit_remaining
  end

  def get_recent_matches(player_id)
    uri = URI("https://api.opendota.com/api/players/#{player_id}/recentMatches")
    res = Net::HTTP.get_response(uri)
    @rate_limit_remaining = [@rate_limit_remaining, res['x-rate-limit-remaining-month'].to_i].min

    JSON.parse(res.body)
  end

  def get_display_name(player_id)
    unless @player_data_cache.key?(player_id)
      uri = URI("https://api.opendota.com/api/players/#{player_id}")
      res = Net::HTTP.get_response(uri)
      @rate_limit_remaining = [@rate_limit_remaining, res['x-rate-limit-remaining-month'].to_i].min
      data_hash = JSON.parse(res.body)
      @player_data_cache[player_id] = data_hash
    end
    data_hash = @player_data_cache[player_id]

    data_hash['profile']['personaname']
  end

  def get_steam_id(player_id)
    unless @player_data_cache.key?(player_id)
      uri = URI("https://api.opendota.com/api/players/#{player_id}")
      res = Net::HTTP.get_response(uri)
      @rate_limit_remaining = [@rate_limit_remaining, res['x-rate-limit-remaining-month'].to_i].min
      data_hash = JSON.parse(res.body)
      @player_data_cache[player_id] = data_hash
    end
    data_hash = @player_data_cache[player_id]

    data_hash['profile']['steamid']
  end

  def get_hero_name(hero_id)
    if @hero_cache.nil?
      uri = URI('https://api.opendota.com/api/heroes')
      res = Net::HTTP.get_response(uri)
      @rate_limit_remaining = [@rate_limit_remaining, res['x-rate-limit-remaining-month'].to_i].min

      @hero_cache = JSON.parse(res.body).map do |hero|
        { 'id' => hero['id'], 'name' => hero['localized_name'] }
      end
    end

    @hero_cache.detect { |hero| hero['id'] == hero_id }['name']
  end

  def get_match_data(match_id)
    uri = URI("https://api.opendota.com/api/matches/#{match_id}")
    res = Net::HTTP.get_response(uri)
    @rate_limit_remaining = [@rate_limit_remaining, res['x-rate-limit-remaining-month'].to_i].min

    JSON.parse(res.body)
  end
end
