#!/usr/bin/env ruby
# references:
# http://rubylearning.com/blog/2011/01/03/how-do-i-make-a-command-line-tool-in-ruby/

require 'pry'
require 'io/console'

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


class ConsoleBars
  attr_accessor :n_rows, :n_columns

  def initialize(screen_cleaner: ScreenCleaner, interpolator: Interpolator)
    @n_rows, @n_columns = $stdout.winsize
    @n_rows = @n_rows - 2

    @screen_cleaner = screen_cleaner.new(screen_with: n_rows)
    @interpolator = interpolator
  end

  def start
    clear_screen

    (1..1000).each do |increment|
      screen_matrix = ScreenMatrix.new(n_rows, n_columns).matrix
      draw_wave(screen_matrix, increment: increment)
      sleep(1.0/24.0)
      clear_screen
    end
  end

  private
  #injected dependencies
  attr_reader :screen_cleaner, :interpolator

  def clear_screen
    screen_cleaner.clear
  end

  def draw_wave(matrix, increment: 1)
    matrix = plot_wave(matrix, increment: increment)
    draw(matrix)
  end

  def draw(matrix)
    max_columns = matrix.first.length-1
    matrix.each do |row|
      row.each_with_index do |content, index|
        print_character(content, index, max_columns)
      end
    end
  end

  def print_character(content, index, max_columns)
    $stdout.print content.nil? ? ' ' : content
    $stdout.puts if (index == max_columns)
  end

  def plot_wave(matrix, increment: 1)
    n_r = matrix.length - 1
    n_c = matrix.first.length - 1

    w_scale_factor = 360/n_c

    y_calculator = scale([-1,1],[0,n_r])
    x_calculator = scale([0,n_c], [0,360])

    (0..n_c).each do |x|
      x_degrees = x_calculator.call(x+increment)
      sin_y = Math.sin(to_radians(x_degrees)) # y is going to be between -1 and 1
      y = y_calculator.call(sin_y).to_i


      # $stdout.puts("X=#{x}\tY=#{y}")
      matrix[y][x] = 'x'
    end

    matrix
  end

  def scale(domain, range)
    u = Interpolator.uninterpolate_number(domain[0], domain[1])
    i = Interpolator.interpolate_number(range[0], range[1])

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
end






module Interpolator
    # Returns a lambda used to determine what number is at t in the range of a and b
  #
  #   interpolate_number(0, 500).call(0.5) # 250
  #   interpolate_number(0, 500).call(1) # 500
  #
  def self.interpolate_number(a, b)
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
  def self.uninterpolate_number(a, b)
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
  def self.scale(domain, range)
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
else
  $stdout.puts 'Use the "start" option moron.'
end
