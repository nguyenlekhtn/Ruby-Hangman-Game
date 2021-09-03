puts 'Hangman Initialized!'

require 'time'
require_relative 'display'
require_relative 'mixin'

class Game
  include HangmanDisplay
  include BasicSerializable
  ATTEMPTS = 6

  def self.new_game
    guesses = []
    secret_word = get_word_from_dictionary
    turn = 0
    Game.new(guesses, secret_word, turn)
  end

  def initialize(guesses, secret_word, turn)
    @guesses = guesses
    @secret_word = secret_word
    @turn = turn
    @incorrect_guesses = compute_incorrect_guesses(guesses, secret_word)
    @status = compute_status(secret_word, guesses)
  end

  attr_reader :board, :incorrect_guesses, :status, :turn

  def self.select_word(word_list, min_length, max_length)
    rand_idx = rand(word_list.length)
    word = word_list[rand_idx]
    if word.length.between?(min_length, max_length)
      word
    else
      filtered_list = word_list.select.with_index { |_v, idx| idx != rand_idx }
      select_word(filtered_list, min_length, max_length)
    end
  end

  def self.load_dictionary
    dictionary = []
    lines = File.readlines('5desk.txt')
    lines.each do |line|
      word = line.strip.downcase
      dictionary << word
    end
    dictionary
  end

  def self.get_word_from_dictionary
    dictionary = load_dictionary
    select_word(dictionary, 5, 12)
  end

  def compute_incorrect_guesses(guesses, secret_word)
    guesses.reject { |letter| secret_word.include? letter }
  end

  def compute_status(secret_word, guesses)
    secret_word.chars.map do |value|
      guesses.include?(value) ? value : '_'
    end
  end

  # def play
  #   dictionary = load_dictionary
  #   self.secret_word = select_word(dictionary, 5, 12)
  #   turn_number = 0
  #   while attempts_left.positive?
  #     display_turn(turn_number)
  #     do_turn
  #     if board.all_opened?
  #       board.display
  #       announce_player_won
  #       return
  #     end
  #     puts "\n"
  #     turn_number += 1
  #   end
  #   annouce_no_attempt_left
  #   annouce_secret_word @secret_word
  # end

  def save_phase
    save_game if player_want_to_save?
  end

  def save_game
    time_formatted = Time.now.strftime('%F_%R')
    filename = "hangman_save_#{time_formatted}"
    save_content = serialize
    File.open(filename, 'w') do |file|
      file.write(save_content)
    end
  end

  def start
    result = play
    if result
      announce_player_won
    else
      annouce_no_attempt_left
      annouce_secret_word(@secret_word)
    end
  end

  private

  def play
    # incorrect_guesses = compute_incorrect_guesses
    return true if all_opened?
    return false if incorrect_guesses.length > ATTEMPTS

    display_turn(turn)
    save_phase unless turn == 0
    annouce_attemps_left(attempts_left)
    annouce_status(status)
    letter = guess_from_player
    if @secret_word.include? letter
      matched_num = update_status_with(letter)
    else
      @incorrect_guesses << letter
      matched_num = 0
    end
    announce_num_match(matched_num, letter)
    @turn += 1
    puts "\n\n"
    play
  end

  def attempts_left
    ATTEMPTS - @incorrect_guesses.length
  end

  def secret_word=(word)
    @secret_word = word
    # puts "Secret word is #{@secret_word}"
    @board = Board.new(@secret_word)
  end

  def guess_from_player
    print 'Guess a letter that the secret word included: '
    loop do
      char = gets.chomp.downcase
      return char if char.match(/^[a-z]$/)

      print 'Invalid character, please type again: '
    end
  end

  def update_status_with(letter)
    matched_indexes = (0...@secret_word.length).find_all { |i| @secret_word[i] == letter }
    # replace _ with letter at indexes in board
    @status = @status.map.with_index { |element, idx| matched_indexes.include?(idx) ? letter : element }
    matched_indexes.length
  end

  def all_opened?
    @status.join == @secret_word
  end

  # return true if guess
  # def do_turn
  #   board.display
  #   annouce_attemps_left attempts_left
  #   letter = player_guess
  #   if @secret_word.include? letter
  #     matched_num = board.update_with letter
  #   else
  #     @incorrect_guesses << letter
  #     matched_num = 0
  #   end
  #   announce_num_match(matched_num, letter)
  # end
end

# class Board
#   def initialize(word)
#     @secret_word = word
#     @board = Array.new(word.length) { '_' }
#   end

#   attr_reader :board

#   def display
#     print 'Board: '
#     puts board.join(' ')
#   end

#   def all_opened?
#     @board.join == @secret_word
#   end

#   def update_with(letter)
#     # get indexes of letter in @secret_word
#     matched_indexes = (0...@secret_word.length).find_all { |i| @secret_word[i] == letter }
#     # replace _ with letter at indexes in board
#     @board = @board.map.with_index { |element, idx| matched_indexes.include?(idx) ? letter : element }
#     matched_indexes.length
#   end
# end
Game.new_game.start
