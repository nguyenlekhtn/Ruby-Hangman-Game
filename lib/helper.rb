module Helper
  def from_input(_text, regexp)
    loop do
      input = gets.chomp
      return input if input.match(regexp)
    end
  end
end
