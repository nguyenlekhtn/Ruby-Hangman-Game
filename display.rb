module HangmanDisplay
  def display_turn(turn_number)
    puts "Turn #{turn_number}"
  end

  def announce_player_won
    puts "\nALl letters are opened. Player won!!"
  end

  def announce_num_match(number, letter)
    letter_word = number <= 1 ? 'letter' : 'letters'
    be = number <= 1 ? 'is' : 'are'
    puts "There #{be} #{number} #{letter_word} '#{letter}' in secret word"
  end

  def annouce_attemps_left(attempts_left)
    puts "You can give #{attempts_left} more incorrect #{attempts_left > 1 ? "guesses" : "guess"} before game ends"
  end

  def plural(number, word)
    "#{number} #{word}#{number > 1 ? 's' : ''}"
  end

  def annouce_no_attempt_left
    puts "\nNo attempt left! Player lose" 
  end

  def annouce_secret_word(word)
    puts "Secret word is '#{word}'"
  end
end
