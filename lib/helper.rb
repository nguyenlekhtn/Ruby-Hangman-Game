# frozen_string_literal: true

module Helper
  def from_input(regexp, rescue_msg)
    loop do
      answer = gets.chomp
      return answer.to_i if answer.match(regexp)

      puts rescue_msg
    end
  end
end
