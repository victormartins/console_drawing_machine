# Plots data into the screen matrix
module Plotters
  class SinWave
    PRINT_CHAR = '.'

    def initialize(interpolator: Interpolator)
      @interpolator = interpolator
    end

    def plot(matrix, frame: 1)
      n_r = matrix.length - 1
      n_c = matrix.first.length - 1

      y_calculator = interpolator.scale([-1, 1],[0, n_r]) # converts the range of sin to the range of the screen
      x_calculator = interpolator.scale([0, n_c], [0, 360])  #converts the range of x in to the range of degrees

      log("[#{frame}]\n")

      # binding.pry
      (0..n_c).each do |row|
        cyclic_row =  (row + frame)%n_c
        x_degrees = x_calculator.call(cyclic_row)
        sin_y = Math.sin(to_radians(x_degrees)) # y is going to be between -1 and 1

        line = y_calculator.call(sin_y).to_i

        line = n_r - line #invert the wave since zero in our matrix is on top left
        log("(#{row.to_s.ljust(4)}, #{line.to_s.ljust(4)})")

        matrix[line][row] = PRINT_CHAR
      end
      log("\n")

      matrix
    end

    private
    attr_reader :interpolator

    def log(content)
      File.open("logs/sin_wave.log", 'a') {|f| f.write(content) }
    end

    def to_radians(degrees)
      degrees * Math::PI / 180
    end
  end
end
