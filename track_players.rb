# frozen_string_literal: true

require "./app/opendota"
require "./app/steamapi"
require "./app/storage"

$storage = Storage.new("data.json")

$opendota = OpenDota.new
$steam_api = SteamAPI.new($storage.get_steam_api_key)

ARGV.map(&:to_i).each do |player_id|
  match_id = # Queue up one match
    $opendota.get_recent_matches(player_id).max_by do |match|
      match["match_id"]
    end
  steam_id = $opendota.get_steam_id(player_id)
  $storage.track_player(player_id, match_id, steam_id)
end
