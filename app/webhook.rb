# frozen_string_literal: true

require "discordrb/webhooks"

class WebHook
  def initialize(webhook)
    @client = Discordrb::Webhooks::Client.new(url: webhook)
  end

  def send_text(text)
    @client.execute do |builder|
      builder.content = text
    end
    sleep(1)
  end

  def send_embed(title, fields)
    @client.execute do |builder|
      builder.add_embed do |embed|
        embed.title = title
        fields.each do |field|
          embed.add_field(name: field[:name], value: field[:value], inline: true)
        end
      end
    end
    sleep(1)
  end
end
