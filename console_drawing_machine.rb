#!/usr/bin/env ruby
# references:
# http://rubylearning.com/blog/2011/01/03/how-do-i-make-a-command-line-tool-in-ruby/

require 'pry'
require 'io/console'

require_relative 'interpolator'
require_relative 'screen_matrix'
require_relative 'screen_cleaner'
require_relative 'printer'
require_relative 'plotters'

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
    @interpolator   = interpolator
    @plotter        = plotter.new
    @printer        = printer.new
    @screen_matrix  = screen_matrix.new(n_rows, n_columns)
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



case ARGV[0]
when "start"
  ConsoleDrawingMachine.new.start
else
  $stdout.puts 'Use the "start" option moron.'
end
