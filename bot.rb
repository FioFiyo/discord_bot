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

# User can call the command !vote and will return a list of current movies
# User can then pass movie name to vote for after prompted
# Movie will have a vote counter and will be compared to the 10 movies and ordered accordingly

# User can call the command !votecount and will return movie list with % of current votes

# Admin can reset movie list
# Admin can reset movie vote
##

#@TODO
# 1. Add rescue clauses
# 2. Finish Admin
# 3. Add votecount command
# 4. Refactor

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
		@votes = Array.new
	end

	def movies
		@movies
	end

	def votes
		@votes
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

		unless defined?(@list)
			@list ||= List.new
			event.respond "A list has being started. To add movies call the !addmovie command"
		else
			event.respond "There's already a list of movies being made. To delete !deletelist"
		end
	else
		event.respond "Not owner"
	end
end

bot.command(:addmovie, description: "Add movie to the list using !addmovie YOUR_MOVIE", :min_args => 1, usage: "!addmovie YOUR_MOVIE_HERE") do |event, *movie|
	
	
	# @notice Join movie array when user passes multiple words & downcase
	movie = movie.join(' ').downcase

	# @dev Lookup movie in List for duplicates
	
	if @list.movies.length == 10
		break event.respond "I can't add any more movies, we got 10 movies already to choose from!"
	end

	unless @list.movies.include?(movie)
		@list.movies.push(movie)
		@list.votes.push({"#{movie}" => 0})
		event.respond "#{movie.capitalize} added to the list."
	else
		event.respond "#{movie.capitalize} is already on the list!"
	end

	if @list.movies.length == 0
		event.respond "The list is empty: #{movie}"
	else
		event.respond "Movie list: #{@list.movies}"
	end
	
end

bot.message(start_with: '!vote') do |event|

	# User vote input
	event.user.await(:vote) do |movie|
	
		movie = movie.message.content.downcase
			
		# @notice Check that the movie is actually on the list

		unless @list.movies.include?(movie)
			 event.respond "This movie isn't in the list. Try !addmovie #{movie}"

			# @dev so we continue listening to the event
			false
		end

		# Add vote to current list

		unless @list.movies.empty?
			
			@list.votes.each_with_index do |m,i|

				if m.keys[0] === movie
					@list.votes[i][m.keys[0]] += 1
					break event.respond "One vote added to #{m.keys[0].capitalize}. #{m.keys[0].capitalize} has now #{m.values[0]} votes."
				end
			end

		else
			event.respond "No movies, no voting. Try !addmovie #{movie}"

			false
		end
	end

	# Show list of current movies
	see_list = "Movies: \n\n" 
	@list.movies.each_with_index do |movie, i|	
		see_list += "#{i += 1}. #{movie.capitalize} \n"
	end
	event.respond "#{see_list}"

	event.respond "Pick a movie from the list above and just type it out!"

end

bot.run

