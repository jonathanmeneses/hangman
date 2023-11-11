# Hangman!
#


words = File.readlines(
  'google-10000-english-no-swears.txt').map(&:chomp)

filtered_words = words.select {|word| word.length>4 && word.length <13}



game_word = filtered_words.sample()

class Hangman
  attr_accessor :secret_word, :remaining_guesses, :guessed_letters, :secret_word_array, :word_display
  def initialize
    @secret_word
    @secret_word_array = []
    @remaining_guesses = 8
    @guessed_letters = []
    @word_display
  end

  def grab_secret_word(data)
    self.secret_word = data.sample()
    self.secret_word_array = self.secret_word.split("")
    self.word_display = "_" * self.secret_word.length
  end

  def get_guess()
    puts "Guess a letter! Repeats will count as an error!"
    guess = gets.chomp
    guess = guess.split("")[0].downcase
  end
  def check_guess(guess)
    self.guessed_letters.push(guess)
    self.guessed_letters.uniq!
    if secret_word.include?(guess)
      update_display(guess)
    else
      p "This letter is not in the answer"
      self.remaining_guesses -=1
    end

  end

  def update_display(guess)
    self.secret_word.each_char.with_index do |char, index|
      if char == guess
        self.word_display[index] = guess
      end
    end
  end

end

game = Hangman.new

game.grab_secret_word(filtered_words)
p "The secret word is #{game.secret_word}"
guess = game.get_guess
game.check_guess(guess)
p game.word_display
