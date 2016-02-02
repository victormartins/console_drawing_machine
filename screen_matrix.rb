# Matrix array that represents the screen
class ScreenMatrix
  attr_reader :width, :height

  def initialize(width, height)
    @width = width
    @height = height
  end

  def new_matrix
    Array.new(width) {Array.new(height)}
  end
end
