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
    # binding.pry

    matrix[0][0] = 'A'
    matrix[0][n_c] = 'Z'

    matrix[1][0] = 'A'
    matrix[1][n_c] = 'Z'

    matrix[2][0] = 'A'
    matrix[2][n_c] = 'Z'

    matrix[n_r][0] = 'A'
    matrix[n_r][n_c] = 'Z'


    matrix.each do |row|
      row.each_with_index do |content, index|
        $stdout.print content.nil? ? '_' : content
        $stdout.puts if (index == n_c)
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

end




case ARGV[0]
when "start"
  ConsoleBars.new.start
end
