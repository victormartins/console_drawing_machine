# Plots data into the screen matrix
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
