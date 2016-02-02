#!/usr/bin/env ruby
# references:
# http://rubylearning.com/blog/2011/01/03/how-do-i-make-a-command-line-tool-in-ruby/

require 'pry'
require 'io/console'

class ConsoleDrawingMachine
  attr_accessor :n_rows, :n_columns

  def initialize( screen_cleaner: ScreenCleaner,
                  plotter:        Plotters::SinWave,
                  screen_matrix:  ScreenMatrix,
                  printer:        Printer)

    @n_rows, @n_columns = $stdout.winsize
    @n_rows = @n_rows - 2
    @debug = false

    # Injected Dependencies
    @screen_cleaner = screen_cleaner.new(screen_with: n_rows)
    @interpolator = interpolator
    @plotter = plotter.new
    @printer = printer.new
    @screen_matrix = screen_matrix.new(n_rows, n_columns)
  end

  def start
    clear_screen unless debug

    (1..10).each do |increment|
      $stdout.puts "increment: #{increment}" if debug
      matrix = screen_matrix.matrix

      matrix = plotter.plot(matrix, frame: increment)
      printer.draw(matrix) unless debug
      pause_screen unless debug
      clear_screen unless debug
    end
  end

  private
  #injected dependencies
  attr_reader :screen_cleaner, :interpolator, :plotter, :screen_matrix, :printer
  attr_reader :debug

  def clear_screen
    screen_cleaner.clear
  end

  def pause_screen
    sleep(1.0/24.0)
  end
end

module Plotters
  class SinWave
    def initialize(interpolator: Interpolator)
      @interpolator = interpolator
    end

    def plot(matrix, frame: 1)
      n_r = matrix.length - 1
      n_c = matrix.first.length - 1

      y_calculator = interpolator.scale([-1,1],[0,n_r])
      x_calculator = interpolator.scale([0,n_c], [0,360])

      (0..n_c).each do |x|
        x_degrees = x_calculator.call(x+frame)
        sin_y = Math.sin(to_radians(x_degrees)) # y is going to be between -1 and 1
        y = y_calculator.call(sin_y).to_i


        $stdout.puts("X=#{x}\tY=#{y}")
        matrix[y][x] = '.'
      end

      matrix
    end

    private
    attr_reader :interpolator

    def to_radians(degrees)
      degrees * Math::PI / 180
    end
  end
end

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

class Printer
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
end

case ARGV[0]
when "start"
  ConsoleDrawingMachine.new.start
else
  $stdout.puts 'Use the "start" option moron.'
end
