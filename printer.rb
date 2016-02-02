# prints the content to the screen
class Printer
  def draw(matrix)
    max_columns = matrix.first.length-1
    matrix.each do |row|
      row.each_with_index do |content, index|
        print_character(content, index, max_columns)
      end
    end
  end

  private
  def print_character(content, index, max_columns)
    $stdout.print content.nil? ? ' ' : content
    $stdout.puts if (index == max_columns)
  end
end
