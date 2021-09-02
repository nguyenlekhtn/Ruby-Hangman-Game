puts 'Hangman Initialized!'

require_relative '../display'

class Game
  include HangmanDisplay
  ATTEMPTS = 6

  def initialize
    @incorrect_guesses = []
    @board = nil
    @secret_word = ''
  end

  attr_reader :board, :incorrect_guesses

  def play
    dictionary = load_dictionary
    self.secret_word = select_word(dictionary, 5, 12)
    turn_number = 0
    while attempts_left.positive?
      display_turn(turn_number)
      do_turn
      if board.all_opened?
        board.display
        announce_player_won
        return
      end
      puts "\n"
      turn_number += 1
    end
    annouce_no_attempt_left
    annouce_secret_word @secret_word
  end

  private

  def attempts_left
    ATTEMPTS - @incorrect_guesses.length
  end

  def secret_word=(word)
    @secret_word = word
    # puts "Secret word is #{@secret_word}"
    @board = Board.new(@secret_word)
  end

  def select_word(word_list, min_length, max_length)
    rand_idx = rand(word_list.length)
    word = word_list[rand_idx]
    if word.length.between?(min_length, max_length)
      word
    else
      filtered_list = word_list.select.with_index { |_v, idx| idx != rand_idx }
      select_word(filtered_list, min_length, max_length)
    end
  end

  def load_dictionary
    dictionary = []
    lines = File.readlines('5desk.txt')
    lines.each do |line|
      word = line.strip.downcase
      dictionary << word
    end
    dictionary
  end

  def player_guess
    print 'Guess a letter that the secret word included: '
    loop do
      char = gets.chomp.downcase
      return char if char.match(/^[a-z]$/)

      print 'Invalid character, please type again: '
    end
  end

  # return true if guess
  def do_turn
    board.display
    annouce_attemps_left attempts_left
    letter = player_guess
    if @secret_word.include? letter
      matched_num = board.update_with letter
    else
      @incorrect_guesses << letter
      matched_num = 0
    end
    announce_num_match(matched_num, letter)
  end
end

class Board
  def initialize(word)
    @secret_word = word
    @board = Array.new(word.length) { '_' }
  end

  attr_reader :board

  def display
    print 'Board: '
    puts board.join(' ')
  end

  def all_opened?
    @board.join == @secret_word
  end

  def update_with(letter)
    # get indexes of letter in @secret_word
    matched_indexes = (0...@secret_word.length).find_all { |i| @secret_word[i] == letter }
    # replace _ with letter at indexes in board
    @board = @board.map.with_index { |element, idx| matched_indexes.include?(idx) ? letter : element }
    matched_indexes.length
  end
end

Game.new.play
