require "./app/constants.rb"
require "./app/env.rb"
require "./app/log.rb"
require "./app/opendota.rb"
require "./app/steamapi.rb"
require "./app/storage.rb"
require "./app/webhook.rb"

$constants = Constants.new("constants.json")
$log = Log.new("./logs")
$storage = Storage.new("data.json")

$opendota = OpenDota.new
$steam_api = SteamAPI.new($storage.get_steam_api_key)
$webhook = WebHook.new($storage.get_webhook_url)

def formatted_match_data_string(display_name, match_data)
  assists = match_data["assists"]
  deaths = match_data["deaths"]
  duration = "%02d:%02d" % [match_data["duration"] / 60, match_data["duration"] % 60]
  game_mode = $constants.get_game_mode(match_data["game_mode"])
  hero = $opendota.get_hero_name(match_data["hero_id"])
  id = match_data["id"]
  kills = match_data["kills"]
  lobby_type = $constants.get_lobby_type(match_data["lobby_type"])
  win = (match_data["player_slot"] < 128 && match_data["radiant_win"]) || (match_data["player_slot"] >= 128 && !match_data["radiant_win"])
  return "#{display_name} | #{hero} | #{lobby_type} | #{game_mode} | #{win ? "**Win**" : "Loss"} | #{duration} | #{kills}/#{deaths}/#{assists}"
end

# Start Main
player_list = $storage.get_player_list

player_summaries = $steam_api.get_player_summaries(player_list.map { |player_id| $storage.get_steam_id(player_id) })
player_list.select! do |player_id|
  steam_id = $storage.get_steam_id(player_id)
  player_summary = player_summaries.detect { |player_summary| player_summary["steamid"] == steam_id }
  # personastate 0 == Offline, 4 == Snooze.
  next (player_summary["personastate"] != 0 && player_summary["personastate"] != 4) || (DateTime.now.to_time.utc.to_i - player_summary["lastlogoff"] < (0.5 * 60 * 60))
end

$log.log("Match checking #{player_list.count} players: #{player_list.join(", ")}")
player_list.each do |player_id|
  $log.log("Match checking #{player_id} | #{$storage.get_display_name(player_id)}")
  new_matches = $opendota.get_recent_matches(player_id).select do |match|
    match["match_id"] > $storage.get_match_id(player_id)
  end

  if new_matches.empty?
    $log.log("No new matches found.")
  else
    $log.log("#{new_matches.count} new matches found.")
    display_name = $opendota.get_display_name(player_id)
    $storage.set_display_name(player_id, display_name)
    steam_id = $opendota.get_steam_id(player_id)
    $storage.set_steam_id(player_id, steam_id)
    $log.log("Display name: #{display_name} | Steam ID: #{steam_id}")
  end

  new_matches.each do |match|
    display_name = $storage.get_display_name(player_id)
    $log.log("Parsing match data to string: #{match}")
    match_string = formatted_match_data_string(display_name, match)
    $log.log(match_string)
    $webhook.send_message(match_string)
    if match["match_id"] > $storage.get_match_id(player_id)
      $log.log("Newest match recorded for #{display_name} is #{match["match_id"]}")
      $storage.set_match_id(player_id, match["match_id"])
    end
  end
end
if (!player_list.empty?)
  $log.log("x-rate-limit-remaining-month: #{$opendota.get_rate_limit_remaining}")
end
$log.log("Match check finished.")
