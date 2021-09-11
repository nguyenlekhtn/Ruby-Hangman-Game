# frozen_string_literal: true

puts 'Hangman Initialized!'
require 'time'
require 'yaml'

require_relative 'display'
require_relative 'mixin'
require_relative 'helper'

class Game
  include HangmanDisplay
  include BasicSerializable
  include Colorize
  include Helper
  ATTEMPTS = 6
  SAVE_DIR = 'save/'

  def self.new_game
    guesses = []
    secret_word = word_from_dictionary
    turn = 0
    Game.new(guesses, secret_word, turn)
  end

  def initialize(guesses, secret_word, turn)
    @guesses = guesses
    @secret_word = secret_word
    @turn = turn
    # @status = compute_status(secret_word, guesses)
    @status = Array.new(@secret_word.length) { '_' }
  end

  attr_reader :board, :status, :turn, :guesses

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

  def self.word_from_dictionary
    dictionary = load_dictionary
    select_word(dictionary, 5, 12)
  end

  def start
    puts green(introduce_game_msg)
    load_phase if save_files_exist? && player_want_to_load?
    result = play
    if result
      puts green(player_won_msg)
    else
      puts green(player_lose_msg)
      puts annouce_secret_word_msg(@secret_word)
    end
  end

  private

  def play
    # incorrect_guesses = compute_incorrect_guesses
    return true if all_opened?
    return false if incorrect_guesses.length > ATTEMPTS

    puts display_turn(turn)
    puts green(annouce_status(status))
    puts annouce_incorrect_guesses(incorrect_guesses)
    puts annouce_attemps_left(attempts_left)
    # loop to continue game after saved
    while true
      answer = guess_from_player
      break unless answer == 'save'

      save_game
    end

    matched_num = if @secret_word.include? answer
                    update_status_with(answer)
                  else
                    0
                  end
    @guesses << answer
    puts num_match_msg(matched_num, answer)
    @turn += 1
    puts

    # recurively play with modified states
    play
  end

  def player_want_to_load?
    puts 'Do you want to load save files?'
    confirm
  end

  def incorrect_guesses
    guesses.reject { |guess| @secret_word.include? guess }
  end

  def guess_from_player
    puts guess_msg
    loop do
      answer = gets.chomp.downcase
      included = guesses.include?(answer)
      return answer if answer.match(/^[a-z]|\bsave\b$/) && !included

      respond_msg = included ? existed_msg : invalid_input_msg
      puts red(respond_msg)
    end
  end

  def compute_incorrect_guesses(guesses, secret_word)
    guesses.reject { |letter| secret_word.include? letter }
  end

  def compute_status(secret_word, guesses)
    secret_word.chars.map do |value|
      guesses.include?(value) ? value : '_'
    end
  end

  def save_game
    Dir.mkdir('save') unless Dir.exist?('save')
    time_formatted = Time.now.strftime('%F_%R')
    filename = "hangman_save_#{time_formatted}"
    filepath = "save/#{filename}"
    save_content = serialize(YAML)
    File.open(filepath, 'w') do |file|
      file.write(save_content)
    end
    puts green(save_done_msg)
  end

  def save_files_exist?
    Dir.exist?(SAVE_DIR) && !Dir.empty?(SAVE_DIR)
  end

  def ask_load_indexes(list)
    print load_instruction_msg
    from_input(/[0-#{list.length}]/, 'Not in valid range, please type again')
  end

  def load_phase
    # show file saves list with indexes
    file_list = Dir.children(SAVE_DIR)
    show_save_list(file_list)
    # ask players to type indexes to choose
    answer = ask_load_indexes(file_list)
    # load the selected files
    return if answer.zero?

    selected_file_name = file_list[answer - 1]
    file_path = "#{SAVE_DIR}#{selected_file_name}"
    begin
      unserialize(serializer: YAML, string: file_path, is_file: true)
    rescue StandardError
      puts "Oops. Can't load the selected file."
    else
      puts load_finished_msg
    end
  end

  def attempts_left
    ATTEMPTS - incorrect_guesses.length
  end

  def secret_word=(word)
    @secret_word = word
    # puts "Secret word is #{@secret_word}"
    @board = Board.new(@secret_word)
  end

  # def guess_from_player
  #   print 'Guess a letter that the secret word included: '
  #   loop do
  #     char = gets.chomp.downcase
  #     return char if char.match(/^[a-z]$/)

  #     print 'Invalid input, please type again: '
  #   end
  # end

  def select_from_player
    text = <<~HEREDOC
      Guess a letter that secret word include
      You can also type 'save' to save the game
    HEREDOC
    puts text
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
end

Game.new_game.start
