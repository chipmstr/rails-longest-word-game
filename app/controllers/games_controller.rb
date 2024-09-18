require 'httparty'

class GamesController < ApplicationController
  # action to render the grid with random letters for a new game
  def new
    # generate a random grid of 10 letters
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }

    # store the start time in the session as a serialized string
    session[:start_time] = Time.now.to_s

    # initialize the total score if not already present
    session[:total_score] ||= 0
  end

  def score
    # retrieve the submitted word from the form
    @word = params[:word]

    # retrieve the letters grid from the form
    @grid = params[:grid].split

    # retrieve and deserializethe start time from the session
    start_time = Time.parse(session[:start_time])

    # calculate time taken to submit the word
    time_taken = Time.now - start_time

    # check if the word is valid in the grid and in the dictionary
    if valid_word_in_grid?(@word, @grid) && valid_word_in_api?(@word)
      # calculate score based on word length and the time taken
      score = calculate_score(@word, time_taken)

      # add score to total score in the session
      session[:total_score] += score

      @result = "<strong>Congratulations!</strong> #{@word.upcase} is a valid English word!"
    elsif !valid_word_in_grid?(@word, @grid)
      # format the grid letters into uppercase and separate them with commas
      formatted_grid = @grid.map(&:upcase).join(", ")
      @result = "Sorry, <strong>#{@word.upcase}</strong> can't be built out of #{formatted_grid}"
    else
      @result = "Sorry, <strong>#{@word.upcase}</strong> does not seem to be a valid English word."
    end

    # display the total score from the session
    @total_score = session[:total_score]
  end

  private

  # method to check if the word can be formed by using the letters from the grid
  def valid_word_in_grid?(word, grid)
    word.upcase.chars.all? { |letter| grid.count(letter) >= word.upcase.count(letter) }
  end

  # method to check if the word is valid in the dictionary API
  def valid_word_in_api?(word)
    url = "https://dictionary.lewagon.com/#{word}"
    begin
      response = HTTParty.get(url)
      response["found"] # returns true if the word is found
    rescue StandardError => e
      Rails.logger.error "Error fetching word from API: #{e.message}"
      false
    end
  end

  # method to calculate the score based on word length and time taken
  def calculate_score(word, time_taken)
    (word.length.to_f / time_taken).round(2)
  end
end
