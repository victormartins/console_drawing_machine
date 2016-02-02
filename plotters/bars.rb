# Plots data into the screen matrix
module Plotters
  class Bars
    PRINT_CHAR = 'X'

    def initialize(interpolator: Interpolator)
      @interpolator = interpolator
    end

    def plot(matrix, frame: 1)
      n_r = matrix.length - 1
      n_c = matrix.first.length - 1

      log("[#{frame}]\n")
      (0..n_c).each do |row|
        line = rand(0..n_r) #column hight

        #column filling
        (0..line).each do |line|
          line = n_r - line
          matrix[line][row] = PRINT_CHAR
        end

        log("(#{row.to_s.ljust(4)}, #{line.to_s.ljust(4)})")
      end
      log("\n")

      matrix
    end

    private
    attr_reader :interpolator

    def log(content)
      File.open("logs/bars.log", 'a') {|f| f.write(content) }
    end

    def to_radians(degrees)
      degrees * Math::PI / 180
    end
  end
end
