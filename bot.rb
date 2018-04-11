require 'discordrb'
require 'configatron'
require_relative 'config.rb'

# @dev Bot initializer
bot = Discordrb::Commands::CommandBot.new token: configatron.token, client_id: 431888998441418773, prefix: "!"

##
# User can call the command !addmovie and pass a movie
# It will be added to a list of movies
# If movie has already being added, it'll send a msg with movie already added
# If movies have reached 10, do not accept any more

# User can call the command !votemovie and will return a list of current movies
# voting based on starting number 1 to 10 
# User can then pass number which maps to a movie
# Movie will have a counter and will be compared to the 10 and ordered accordingly

# User can call the command !votecount and will return movie list with % of current votes

# Admin can reset movie list
# Admin can reset movie vote
##

# @notice ID is a public client ID on Discord

module Owner
	ID = 347882263754702848.freeze

	def self.id
		ID
	end
end

class Admin
	include Owner

	def reset_list
		#@TODO
	end

	def reset_vote
		#@TODO
	end

end

class List 
	include Owner 

	def initialize
		@movies = []
		@owner = Owner.id
	end

	def movies
		@movies
	end

	def is_owner?
		self.check_owner
	end

	protected

	def check_owner
		if @owner === Owner.id
			return true
		else
			return false
		end
	end

end

bot.command(:startlist, description: "Starts list for movies to be added", usage: "!startlist") do |event|

	if event.user.id === Owner.id
		LIST = List.new
		event.respond "A list has being started. To add movies call the !addmovie command"
	else
		event.respond "Not owner"
	end
end

bot.command(:addmovie, description: "Add movie to the list using !addmovie YOUR_MOVIE", :min_args => 1, usage: "!addmovie YOUR_MOVIE_HERE") do |event, *movie|
	
	
	# @notice Join movie array when user passes multiple words & downcase
	movie = movie.join(' ').downcase

	# @dev Lookup movie in List for duplicates
	
	if LIST.movies.length == 10
		break event.respond "I can't add any more movies, we got 10 movies already to choose from!"
	end

	unless LIST.movies.include?(movie)
		LIST.movies.push(movie)
		event.respond "#{movie.capitalize} added to the list."
	else
		event.respond "#{movie.capitalize} is already on the list!"
	end


	if LIST.movies.length == 0
		event.respond "The list is empty: #{movie}"
	else
		event.respond "Movie list: #{LIST.movies}"
	end
	
end

# @TODO
bot.command(:votemovie, description: "Pick a movie from the list and vote!", usage: "!votemovie YOUR_MOVIE_HERE") do |event, *movie|

	# @dev Check if user is picking movie from the list

	movie = movie.join(' ').downcase


end

bot.run

