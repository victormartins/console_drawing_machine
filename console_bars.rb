#!/usr/bin/env ruby
# references:
# http://rubylearning.com/blog/2011/01/03/how-do-i-make-a-command-line-tool-in-ruby/

require 'pry'
require 'io/console'


class ConsoleBars
  attr_accessor :n_rows, :n_columns

  def initialize
    @n_rows, @n_columns = $stdout.winsize
  end

  def start
    clear_screen

    screen_matrix = ScreenMatrix.new(n_rows, n_columns).matrix

    draw_wave(screen_matrix)
  end

  def clear_screen
    n = 0
    while n < n_rows
      $stdout.puts ''
      n = n + 1
    end
  end

  def draw_wave(matrix)
    n_r = matrix.length - 1
    n_c = matrix.first.length - 1

    matrix = plot_wave(matrix)

    matrix.each do |row|
      row.each_with_index do |content, index|
        print_character(content, index, n_c)
      end
    end
  end

  def print_character(content, index, n_c)
    $stdout.print content.nil? ? ' ' : content
    $stdout.puts if (index == n_c)
  end

  def plot_wave(matrix)
    n_r = matrix.length - 1
    n_c = matrix.first.length - 1

    w_scale_factor = 360/n_c

    y_calculator = scale([-1,1],[0,n_r])
    x_calculator = scale([0,n_c], [0,360])

    (0..n_c).each do |x|
      x_degrees = x_calculator.call(x)
      sin_y = Math.sin(to_radians(x_degrees)) # y is going to be between -1 and 1
      y = y_calculator.call(sin_y).to_i


      $stdout.puts("X=#{x}\tY=#{y}")
      matrix[y][x] = 'x'
    end

    matrix
  end

  def scale(domain, range)
    u = uninterpolate_number(domain[0], domain[1])
    i = interpolate_number(range[0], range[1])

    lambda do |x|
      x = ([domain[0], x, domain[1]].sort[1]).to_f
      i.call(u.call(x))
    end
  end

  def to_radians(degrees)
    degrees * Math::PI / 180
  end
  #
  # def to_degrees(radians)
  #   radians / Math::PI / 180
  # end

  class ScreenMatrix
    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
    end

    def matrix
      Array.new(width) {Array.new(height)}
    end
  end








    # Returns a lambda used to determine what number is at t in the range of a and b
  #
  #   interpolate_number(0, 500).call(0.5) # 250
  #   interpolate_number(0, 500).call(1) # 500
  #
  def interpolate_number(a, b)
    a = a.to_f
    b = b.to_f
    b -= a
    lambda { |t| a + b * t }
  end

  # Returns a lambda used to determine where t lies between a and b with an ouput
  # range of 0 and 1
  #
  #   uninterpolate_number(0, 500).call(0)   # 0
  #   uninterpolate_number(0, 500).call(250) # 0.5
  #   uninterpolate_number(0, 500).call(500) # 1.0
  #
  def uninterpolate_number(a, b)
    a = a.to_f
    b = b.to_f
    b = b - a > 0 ? 1 / (b - a) : 0

    lambda { |x| (x - a) * b }
  end

  # Returns a closure with the specified input domain and output range
  #
  #   score = scale([0, 500], [0, 1.0])
  #
  #   score.call(0) = 0
  #   score.call(250) = 0.5
  #   score.call(500) = 1.0
  #
  #
  # domain - Array. Input domain
  # range  - Array. Output range
  #
  # Returns lambda
  def scale(domain, range)
    u = uninterpolate_number(domain[0], domain[1])
    i = interpolate_number(range[0], range[1])

    lambda do |x|
      x = ([domain[0], x, domain[1]].sort[1]).to_f
      i.call(u.call(x))
    end
  end

end




case ARGV[0]
when "start"
  ConsoleBars.new.start
end
