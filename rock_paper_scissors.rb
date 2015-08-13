def determine_winner(user_choice, computer_choice)
  if user_choice == computer_choice
    :tie
  elsif user_choice == "Rock"
    computer_choice == "Scissors" # Returns true for win, false for loss
  elsif user_choice == "Paper"
    computer_choice == "Rock"
  elsif user_choice == "Scissors"
    computer_choice == "Paper"
  end
end

def display_winning_message(winner, user_choice, computer_choice)
  if winner == :tie
    puts "It's a tie!"
  else
    winning_choice = winner ? user_choice : computer_choice
    if winning_choice == "Rock"
      puts "Rock smashes Scissors!" 
    elsif winning_choice == "Scissors"
      puts "Scissors cuts Paper!" 
    else
      puts "Paper wraps Rock!"
    end
    puts message = winner ? "You won!" : "You lost!"
  end
end

CHOICES = ["Rock", "Paper", "Scissors"]

puts "Play Rock Paper Scissors!"

loop do 
  puts "Choose one: (P/R/S)"
  user_choice = case gets.chomp.downcase
                when "r" then "Rock"
                when "p" then "Paper"
                when "s" then "Scissors"
                end
  next unless choices.include?(user_choice)
  computer_choice = CHOICES.sample
  
  display_winning_message(determine_winner(user_choice, computer_choice), user_choice, computer_choice)
  
  puts "Play again? (y/n)"
  break unless gets.chomp.downcase == "y"

end

puts "Good bye!"
