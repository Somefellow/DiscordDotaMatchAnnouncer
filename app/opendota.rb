require "json"
require "net/http"
require "uri"

class OpenDota
  def initialize
    @hero_cache = nil
    @player_data_cache = Hash.new
    @rate_limit_remaining = 50000 # x-rate-limit-remaining-month
  end

  def get_rate_limit_remaining
    return @rate_limit_remaining
  end

  def get_recent_matches(player_id)
    uri = URI("https://api.opendota.com/api/players/#{player_id}/recentMatches")
    res = Net::HTTP.get_response(uri)
    @rate_limit_remaining = res["x-rate-limit-remaining-month"].to_i if res["x-rate-limit-remaining-month"].to_i < @rate_limit_remaining
    data_hash = JSON.parse(res.body)
    return data_hash if res.is_a?(Net::HTTPSuccess)
  end

  def get_display_name(player_id)
    if not @player_data_cache.key?(player_id)
      uri = URI("https://api.opendota.com/api/players/#{player_id}")
      res = Net::HTTP.get_response(uri)
      @rate_limit_remaining = res["x-rate-limit-remaining-month"].to_i if res["x-rate-limit-remaining-month"].to_i < @rate_limit_remaining
      data_hash = JSON.parse(res.body)
      @player_data_cache[player_id] = data_hash if res.is_a?(Net::HTTPSuccess)
    end
    data_hash = @player_data_cache[player_id]
    return data_hash["profile"]["personaname"]
  end

  def get_steam_id(player_id)
    if not @player_data_cache.key?(player_id)
      uri = URI("https://api.opendota.com/api/players/#{player_id}")
      res = Net::HTTP.get_response(uri)
      @rate_limit_remaining = res["x-rate-limit-remaining-month"].to_i if res["x-rate-limit-remaining-month"].to_i < @rate_limit_remaining
      data_hash = JSON.parse(res.body)
      @player_data_cache[player_id] = data_hash if res.is_a?(Net::HTTPSuccess)
    end
    data_hash = @player_data_cache[player_id]
    return data_hash["profile"]["steamid"]
  end

  def get_hero_name(hero_id)
    if @hero_cache.nil?
      uri = URI("https://api.opendota.com/api/heroes")
      res = Net::HTTP.get_response(uri)
      @rate_limit_remaining = res["x-rate-limit-remaining-month"].to_i if res["x-rate-limit-remaining-month"].to_i < @rate_limit_remaining
      @hero_cache = JSON.parse(res.body).map { |hero| { "id" => hero["id"], "name" => hero["localized_name"] } } if res.is_a?(Net::HTTPSuccess)
    end
    return @hero_cache.detect { |hero| hero["id"] == hero_id }["name"]
  end

  def get_match_data(match_id)
    uri = URI("https://api.opendota.com/api/matches/#{match_id}")
    res = Net::HTTP.get_response(uri)
    @rate_limit_remaining = res["x-rate-limit-remaining-month"].to_i if res["x-rate-limit-remaining-month"].to_i < @rate_limit_remaining
    data_hash = JSON.parse(res.body)
    return data_hash if res.is_a?(Net::HTTPSuccess)
  end
end
