require "discordrb/webhooks"

class WebHook
  def initialize(webhook)
    @webhook = webhook
  end

  def send_message(message_content)
    client = Discordrb::Webhooks::Client.new(url: @webhook)
    client.execute do |builder|
      builder.content = message_content
    end
    sleep(1)
  end
end
