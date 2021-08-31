puts 'Hangman Initialized!'

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

class Game
  def initialize
    @missed_words = []
    @secret_word = ''
  end

  attr_reader :missed_words, :secret_word

  def play
    dictionary = load_dictionary
    @secret_word = select_word(dictionary, 5, 12)
    while missed_words.length < 6
      # player guess -> letter
      # if letters in secret_word
      # update the display
      # else then add letter to missed_word
    end
  end
end
