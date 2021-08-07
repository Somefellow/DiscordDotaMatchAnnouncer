# frozen_string_literal: true

require './app/constants'
require './app/log'
require './app/match_parse_queue'
require './app/opendota'
require './app/steamapi'
require './app/storage'
require './app/util'
require './app/webhook'

$constants = Constants.new('constants.json')
$log = Log.new('./logs')
$storage = Storage.new('data.json')

$match_parse_queue = MatchParseQueue.new
$opendota = OpenDota.new
$steam_api = SteamAPI.new($storage.get_steam_api_key)
$webhook = WebHook.new($storage.get_webhook_url)

def parse_match_data(player_id, display_name, match_data)
  { :id => match_data['match_id'],
    :player_id => player_id,
    :display_name => display_name,
    :hero => $opendota.get_hero_name(match_data['hero_id']),
    :lobby_type => $constants.get_lobby_type(match_data['lobby_type']),
    :game_mode => $constants.get_game_mode(match_data['game_mode']),
    :win => if (match_data['player_slot'] < 128 && match_data['radiant_win']) ||
               (match_data['player_slot'] >= 128 && !match_data['radiant_win'])
              '**Win**'
            else
              'Loss'
            end,
    :duration => format('%02<minutes>d:%02<seconds>d',
                        { :minutes => match_data['duration'] / 60, :seconds => match_data['duration'] % 60 }),
    :kda => "#{match_data['kills']}/#{match_data['deaths']}/#{match_data['assists']}" }
end

# Start Main
player_list = $storage.get_player_list

player_summaries = $steam_api.get_player_summaries(player_list.map { |player_id| $storage.get_steam_id(player_id) })
player_list.select! do |player_id|
  steam_id = $storage.get_steam_id(player_id)
  matched_player_summary = player_summaries.detect { |player_summary| player_summary['steamid'] == steam_id }
  # personastate 0 == Offline, 4 == Snooze.
  next (matched_player_summary['personastate'] != 0 && matched_player_summary['personastate'] != 4) ||
    (DateTime.now.to_time.utc.to_i - matched_player_summary['lastlogoff'] < (0.5 * 60 * 60))
end

$log.log("Match checking #{player_list.count} players: #{player_list.join(', ')}")
player_list.each do |player_id|
  $log.log("Match checking #{player_id} | #{$storage.get_display_name(player_id)}")
  new_matches = $opendota.get_recent_matches(player_id).select do |match|
    match['match_id'] > $storage.get_match_id(player_id)
  end

  if new_matches.empty?
    $log.log('No new matches found.')
  else
    $log.log("#{new_matches.count} new matches found.")
    display_name = $opendota.get_display_name(player_id)
    $storage.set_display_name(player_id, display_name)
    steam_id = $opendota.get_steam_id(player_id)
    $storage.set_steam_id(player_id, steam_id)
    $log.log("Display name: #{display_name} | Steam ID: #{steam_id}")
  end

  new_matches.each do |match_data|
    display_name = $storage.get_display_name(player_id)
    $log.log("Found new match for #{display_name}: #{match_data}")
    parsed_match_data = parse_match_data(player_id, display_name, match_data)
    $log.log("Parsed match: #{parsed_match_data}")
    $match_parse_queue.add(parsed_match_data)
  end
end

$match_parse_queue.get_match_ids.each do |match_id|
  match_data = $match_parse_queue.get_match_data(match_id)
  if match_data.count == 1
    text = [
      match_data[0][:display_name],
      match_data[0][:hero],
      match_data[0][:lobby_type],
      match_data[0][:game_mode],
      match_data[0][:win],
      match_data[0][:duration],
      match_data[0][:kda],
    ].join(' | ')
    $log.log("Sending solo match to webhook: #{text}")
    $webhook.send_text(text)
  else
    embed_data = {
      :title => [
        match_data[0][:lobby_type],
        match_data[0][:game_mode],
        match_data[0][:win],
        match_data[0][:duration],
      ].join(' | '),
      :fields => match_data.map do |match|
        {
          :name => match[:display_name],
          :value => [match[:hero], match[:kda]].join(' '),
        }
    }
    $log.log("Sending team match to webhook: #{embed_data}")
    $webhook.send_embed(embed_data[:title], embed_data[:fields])
  end
  match_data.each do |match|
    if match[:id] > $storage.get_match_id(match[:player_id])
      $log.log("Newest match recorded for #{match[:display_name]} is #{match[:id]}")
      $storage.set_match_id(match[:player_id], match[:id])
    end
  end
end

$log.log("x-rate-limit-remaining-month: #{$opendota.get_rate_limit_remaining}") unless player_list.empty?
rate_limit_surplus_deficit = $opendota.get_rate_limit_remaining - (50_000 - (Util.month_fraction * 50_000).to_i)
if rate_limit_surplus_deficit.positive?
  $log.log("You have a surplus of #{rate_limit_surplus_deficit} rate limit for this month.")
elsif rate_limit_surplus_deficit.negative?
  $log.log("You have a deficit of #{rate_limit_surplus_deficit} rate limit for this month.")
else
  $log.log('Rate limit usage on track to run out on the end of the month.')
end
$log.log('Match check finished.')
