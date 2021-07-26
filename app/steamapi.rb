# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

class SteamAPI
  def initialize(key)
    @key = key
  end

  def get_player_summaries(steam_ids)
    uri = URI("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{@key}&steamids=#{steam_ids.join(",")}")
    res = Net::HTTP.get_response(uri)
    data_hash = JSON.parse(res.body)
    return data_hash["response"]["players"] if res.is_a?(Net::HTTPSuccess)
  end
end
