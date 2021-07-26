# frozen_string_literal: true

class MatchParseQueue
  def initialize
    @matches = {}
  end

  def add(match_data)
    @matches[match_data[:id]] = [] unless @matches.key?(match_data[:id])
    @matches[match_data[:id]].push(match_data)
  end

  def get_match_ids
    return @matches.keys
  end

  def get_match_data(match_id)
    return @matches[match_id]
  end
end
