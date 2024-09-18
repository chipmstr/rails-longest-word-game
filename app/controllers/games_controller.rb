class GamesController < ApplicationController
  def new
    # generate a random grid with 10 letters
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    # retrieve the submitted word from the form
    @word = params[:word]

    # retrieve the letters grid from the form
    @grid = params[:grid].split

    # initialize session score if it doesn't exist
    session[:total_score] ||= 0

    # check if the word is valid in the grid and in the dictionary
    if valid_word_in_grid?(@word, @grid) && valid_word_in_api?(@word)
      @result = "<strong>Congratulations!</strong> #{@word.upcase} is a valid english word!"

      # add the word length to the session total score
      session[:total_score] += @word.length
    elsif !valid_word_in_grid?(@word, @grid)
      # format the grid letters into uppercase and seperate them with commas
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
end
