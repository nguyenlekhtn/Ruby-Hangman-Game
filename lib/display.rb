# frozen_string_literal: true

module HangmanDisplay
  def display_turn(turn_number)
    "Turn #{turn_number}"
  end

  def player_won_msg
    "\nALl letters are opened. Player won!!"
  end

  def num_match_msg(number, letter)
    letter_word = number <= 1 ? 'letter' : 'letters'
    be = number <= 1 ? 'is' : 'are'
    "There #{be} #{number} #{letter_word} '#{letter}' in secret word"
  end

  def annouce_attemps_left(attempts_left)
    text = "You can give #{attempts_left} more incorrect #{attempts_left > 1 ? 'guesses' : 'guess'} before game ends"
    puts red(text)
  end

  def plural(number, word)
    "#{number} #{word}#{number > 1 ? 's' : ''}"
  end

  def player_lose_msg
    "\nNo attempt left! Player lose"
  end

  def annouce_secret_word_msg(word)
    "Secret word is '#{word}'"
  end

  def annouce_status(status)
    <<~HEREDOC

      Current status:
      #{status.join(' ')}

    HEREDOC
  end

  def annouce_incorrect_guesses(list)
    <<~HEREDOC
      Your incorrect_guesses: #{list.join(', ')}

    HEREDOC
  end

  def existed_msg
    <<~MSG
      You already guess this letter in previous turns
    MSG
  end

  def invalid_input_msg
    <<~MSG
      Invalid input
    MSG
  end

  def guess_msg
    <<~HEREDOC
      Guess a letter that secret word include
      You can also type 'save' to save the game
    HEREDOC
  end

  def save_done_msg
    "Saved. You can press 'Ctrl + C' to exit game now if you want"
  end

  # def player_want_to_save?
  #   puts 'Do you want to save current state?'
  #   confirm
  # end

  def introduce_game_msg
    <<~MSG
      This Hangman game selects a random word from a text file.

      Player's mission is to guess all letters included in the secret word.
      After 6 inccorected guesses, the game will end.

      Each turn, player can choose to save the current state to disk.
      At the start of the game, game will check if save files exists and ask if player wants to load saves.
      Loading one file save will restote the state of the game storing in the file.\s
    MSG
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

  def load_instruction_msg
    <<~MSG
      Type the indexes of the file save you want to load, start from 1
      Press '0' to skip loading and play new game:\s
    MSG
  end

  def show_save_list(list)
    puts 'Save files:'
    list.each_with_index do |filename, idx|
      puts "#{idx + 1} - #{filename}"
    end
  end

  def load_finished_msg
    'Loaded save files'
  end
end

module Colorize
  def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def red(text)
    colorize(text, 31)
  end

  def green(text)
    colorize(text, 32)
  end
end
