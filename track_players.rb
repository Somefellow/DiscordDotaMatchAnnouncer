require "./app/opendota.rb"
require "./app/steamapi.rb"
require "./app/storage.rb"

$storage = Storage.new("data.json")

$opendota = OpenDota.new
$steam_api = SteamAPI.new($storage.get_steam_api_key)

ARGV.map(&:to_i).each do |player_id|
  match_id = $opendota.get_recent_matches(player_id).max_by { |match| match["match_id"] }["match_id"] - 1 # Queue up one match
  steam_id = $opendota.get_steam_id(player_id)
  $storage.track_player(player_id, match_id, steam_id)
end
