# frozen_string_literal: true

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
    puts "You can give #{attempts_left} more incorrect #{attempts_left > 1 ? 'guesses' : 'guess'} before game ends"
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

  def annouce_status(status)
    puts "\n"
    puts 'Current status: '
    puts status.join(' ')
  end

  def annouce_incorrect_guesses(list)
    puts "Your incorrect_guesses: #{list.join(', ')}"
    puts "\n"
  end

  def annouce_save_done
    puts "Saved. You can press 'Ctrl + C' to exit game now if you want"
  end

  def player_want_to_save?
    puts 'Do you want to save current state?'
    confirm
  end

  def seperator_lines
    ''.rjust(10, '-')
  end

  def confirm
    print "Press 'y' to accept, press 'Enter' key or others to skip: "
    answer = gets.chomp
    return true if answer.match(/y/i)

    false
  end

  def player_want_to_load?
    puts 'Do you want to load save files?'
    confirm
  end

  def ask_load_indexes(list)
    puts 'Type the indexes of the file save you want to load, start from 1'
    print "Press '0' to skip loading and play new game: "
    loop do
      answer = gets.chomp
      return answer.to_i if answer.match(/[0-#{list.length}]/)

      puts 'Not in valid range, please type again'
    end
  end

  def show_save_list(list)
    puts 'Save files:'
    list.each_with_index do |filename, idx|
      puts "#{idx + 1} - #{filename}"
    end
  end

  def annouce_load_finished
    puts 'Loaded save files'
  end
end
