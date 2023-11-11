require 'yaml'
require 'byebug'

MY_FILE = 'google-10000-english-no-swears.txt'

class Hangman
  attr_accessor :secret_word, :remaining_guesses, :guessed_letters, :word_display, :game_status
  attr_reader :word_list
  def initialize(dictionary_file)
    @remaining_guesses = 8
    @guessed_letters = []
    @word_display
    @game_status = "playing"
    @word_list = load_words(dictionary_file)
    @secret_word = select_word
  end

  def save_game()
    game_state = {
      remaining_guesses: self.remaining_guesses,
      guessed_letters: self.guessed_letters,
      word_display: self.word_display,
      secret_word: self.secret_word
    }

    yaml = YAML.dump(game_state)
    File.write("hangman_save.yml",yaml)
    self.game_status = 'saved'
    return nil
  end

  def load_game()
    return nil unless File.exist?("hangman_save.yml")
    file = YAML.load_file('hangman_save.yml')
    self.remaining_guesses =  file[:remaining_guesses]
    self.guessed_letters = file[:guessed_letters]
    self.word_display = file[:word_display]
    self.game_status = file[:game_status]
    self.secret_word = file[:secret_word]
    return true
  end

  def load_words(file)
    words = File.readlines(
      file).map(&:chomp)
    words.select {|word| word.length>4 && word.length <13}
  end

  def select_word
    secret_word = @word_list.sample
    self.word_display = "_" * secret_word.length
    secret_word
  end

  def get_guess()
    puts "Guess a letter! Repeats will count as an error!"
    guess = gets.chomp
    if guess ==='save'
      guess = guess
    else
      guess = guess.split("")[0].downcase

    end
    return guess
  end

  def check_guess(guess)

    if guessed_letters.include?(guess)
      self.remaining_guesses -=1
      puts "This letter has already been guessed"
      puts "You've been penalized 1 guess"
      puts "Incorrect guesses remainind: #{self.remaining_guesses}"
    elsif self.secret_word.include?(guess)
      puts "This letter is in the answer!"
      update_display(guess)
    else
      puts "This letter is not in the answer!"
      self.remaining_guesses -=1
      puts "Incorrect guesses remaining: #{self.remaining_guesses}"
    end

    self.guessed_letters.push(guess)
    self.guessed_letters.uniq!


  end

  def update_display(guess)
    self.secret_word.each_char.with_index do |char, index|
      if char == guess
        self.word_display[index] = guess
      end
    end
  end

  def game_turn()
    puts
    puts "\n\n"
    puts self.word_display
    guess = self.get_guess
    # byebug
    if guess === 'save'
      self.save_game
      self.game_status = "save"
    else
      self.check_guess(guess)
      if !word_display.include?("_")
        self.game_status = "win"
      elsif self.remaining_guesses == 0
        self.game_status = "lose"
      end
    end
  end

  def play_game()
    puts "Welcome to Hangman!"
    puts "Would you like to start a new game, or load the last game?"
    puts "Type n for new, and l for load!"
    load_option = ''
    until load_option === 'n' || load_option === 'l'
      load_option = gets.chomp
    end

    if load_option === 'l'
      game = self.load_game
    end

    if game
      self.game_status = "playing"
      puts "Previous words #{self.guessed_letters} \n"
    else
      self.secret_word = self.select_word
    end


    while game_status == "playing"
      self.game_turn
    end

    if game_status == 'save'
      puts "game saved!"
    else
      puts "You #{self.game_status}! The word was #{self.secret_word}"
      if File.exist?("hangman_save.yml")
        File.delete("hangman_save.yml")
      end
    end
  end
end

game = Hangman.new(MY_FILE)
game.play_game
