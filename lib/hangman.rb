# frozen_string_literal: true

puts 'Hangman Initialized!'
require 'time'
require_relative 'display'
require_relative 'mixin'
require 'yaml'

class Game
  include HangmanDisplay
  include BasicSerializable
  ATTEMPTS = 6
  SAVE_DIR = 'save/'

  def self.started_from_save
    guesses = []
    secret_word = word_from_dictionary
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

  def self.word_from_dictionary
    dictionary = load_dictionary
    select_word(dictionary, 5, 12)
  end

  def start
    if save_files_exist? && player_want_to_load?
      load_phase
      started_from_save = true
    else
      started_from_save = false
    end
    result = play(started_from_save: started_from_save)
    if result
      announce_player_won
    else
      annouce_no_attempt_left
      annouce_secret_word(@secret_word)
    end
  end

  private

  def play(started_from_save:)
    # incorrect_guesses = compute_incorrect_guesses
    return true if all_opened?
    return false if incorrect_guesses.length > ATTEMPTS

    display_turn(turn)
    annouce_status(status)
    annouce_incorrect_guesses(incorrect_guesses)
    save_phase if !started_from_save && !turn.zero?
    puts "\n"
    annouce_attemps_left(attempts_left)
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
    play(started_from_save: false)
  end

  def compute_incorrect_guesses(guesses, secret_word)
    guesses.reject { |letter| secret_word.include? letter }
  end

  def compute_status(secret_word, guesses)
    secret_word.chars.map do |value|
      guesses.include?(value) ? value : '_'
    end
  end

  def save_phase
    return unless player_want_to_save?

    save_game
    annouce_save_done
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
  end

  def save_files_exist?
    Dir.exist?(SAVE_DIR) && !Dir.empty?(SAVE_DIR)
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
      annouce_load_finished
    end
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
end

Game.started_from_save.start
