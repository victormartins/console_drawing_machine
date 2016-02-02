# class to clean the screen
class ScreenCleaner
  attr_reader :screen_with

  def initialize(screen_with: screen_with)
    @screen_with = screen_with
  end

  def clear
    n = 0
    while n < screen_with
      $stdout.puts ''
      n = n + 1
    end
  end
end
