# Plots data into the screen matrix
module Plotters
  class MiddleLine
    PRINT_CHAR_H = '-'
    PRINT_CHAR_V = '|'
    PRINT_CHAR_CENTER = '+'

    def initialize(interpolator: Interpolator)
      @interpolator = interpolator
    end

    def plot(matrix, frame: 1)
      n_r = matrix.length - 1
      n_c = matrix.first.length - 1

      (0..n_c).each do |row|
        matrix[(n_r/2).to_i][row] = PRINT_CHAR_H
      end

      (0..n_r).each do |line|
        matrix[line][(n_c/2).to_i] = PRINT_CHAR_V
      end

      matrix[(n_r/2).to_i][(n_c/2).to_i] = PRINT_CHAR_CENTER

      matrix
    end

    private
    attr_reader :interpolator

    def to_radians(degrees)
      degrees * Math::PI / 180
    end
  end
end
