# a customized Mechanize for BlueDot spidering.

class BlueDotBot < Mechanize

  # TODO: update web site so the link is real
  BLUE_DOT_BOT_AGENT = "BlueDotBot/1.0 (+http://bluedot.com/bots.html)"

  def initialize(*args)
    super(*args)
    self.user_agent = BLUE_DOT_BOT_AGENT
  end

end
