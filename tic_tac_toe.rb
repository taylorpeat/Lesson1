WINNING_COMBOS = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]

DISPLAY_TEMPLATE = { x: ['   .   .   ', '    \ /    ', '     /     ', '    / \    ', '   .   .   '],
                     o: ['   .--.    ', '  :    :   ', '  |    |   ', '  :    ;   ', '   `--\'    '],
                     b: [' ' * 11, ' ' * 11, ' ' * 11, ' ' * 11, ' ' * 11] }


def select_difficulty
  puts "Please select your difficulty (easy/hard)"
  loop do 
    difficulty = gets.chomp.downcase
    return difficulty if difficulty == "easy" || difficulty == "hard"
    puts "That is not a valid selection.\nPlease re-enter your difficulty. (easy/hard)"
  end
end

def initialize_board
  b = {}
  (1..9).each {|position| b[position] = :b}
  b
end

def update_board(current_board, loc)
  i = 1
  puts
  loop do
    j = 0
    5.times do
      puts "#{DISPLAY_TEMPLATE[current_board[i]][j]}|#{DISPLAY_TEMPLATE[current_board[i+1]][j]}"\
           "|#{DISPLAY_TEMPLATE[current_board[i+2]][j]}"
      j += 1
    end
    break if i > 4
    puts "-----------+-----------+-----------"
    i += 3
  end
  spacer = ' ' * 15
  puts
  puts "Select an available location between 1 and 9"
  puts format("\n%s %s | %s | %s\n%s---+---+---\n%s %s | %s | %s\n%s---+---+---\n%s %s | %s | %s\n",
              spacer, loc[0], loc[1], loc[2], spacer, spacer, loc[3], loc[4], loc[5], spacer, spacer,
              loc[6], loc[7], loc[8])
end

def check_winner(current_board, x_or_o)
  player_numbers = current_board.select { |num, sq| sq == x_or_o }
  return WINNING_COMBOS.any? do |combo|
    combo.all? { |combo_num| player_numbers.include?(combo_num) }
  end
end

def advanced_computer_spot_selection(current_board)
  user_numbers = current_board.select { |num, sq| sq == :x }
  computer_numbers = current_board.select { |num, sq| sq == :o }
  # Check for critical offensive square
  computer_spot = find_critical_square(computer_numbers, user_numbers)
  # Check for critical defensive square
  computer_spot ||= find_critical_square(user_numbers, computer_numbers)
  # Determine best square if none critical
  computer_spot ||= find_best_square(user_numbers, computer_numbers)
  computer_spot ||= 5 if current_board[5] == :b
  computer_spot
end

def find_critical_square(p1_numbers, p2_numbers)
  WINNING_COMBOS.each do |combo|
    i = 0
    strategic_square = nil
    combo.each do |sq|
      if p1_numbers.include?(sq)
        i += 1
      else
        strategic_square = sq unless p2_numbers.include?(sq)
      end
    end
    return strategic_square if strategic_square && i == 2
  end
  nil
end

def find_best_square(user_numbers, computer_numbers)
  users_winning_combos = WINNING_COMBOS.select do |combo|
    combo.all? { |sq| !computer_numbers.include?(sq) } && combo.any? { |sq| user_numbers.include?(sq) }
  end
  computers_winning_combos = WINNING_COMBOS.select do |combo|
    combo.all? { |sq| !user_numbers.include?(sq) } && combo.any? { |sq| computer_numbers.include?(sq) }
  end
  fork_opportunities = find_fork_opportunities(users_winning_combos, user_numbers)
  # If two fork opportunities avoid block, play offense / if one opportunity block
  if fork_opportunities.length > 1
    computers_winning_combos.flatten.select { |num| !computer_numbers.include?(num) && !fork_opportunities.include?(num) }.sample
  else
    fork_opportunities[0]
  end
end

def find_fork_opportunities(users_winning_combos, user_numbers)
  fork_opportunities = []
  users_winning_combos.each do |combo|
    combo.each do |num|
      i = 0
      users_winning_combos.each do |combo_reference|
        i += 1 if combo_reference.include?(num) && !user_numbers.include?(num)
      end
      if i > 1
        fork_opportunities << num unless fork_opportunities.include?(num)
      end
    end
  end
  fork_opportunities
end

def display_winner_message(winner, difficulty)
  puts
  sleep 1
  if winner == :user
    puts "Congratulations! You won!"
    sleep 1
    puts "\nOn easy...\n\n"
    sleep 1
  elsif winner == :computer
    puts "You lost at tic-tac-toe... that's embarrasing.\n\n"
    sleep 1
  else
    puts "Tied. Try it on easy if you feel like winning...\n\n"
    sleep 1
    if difficulty == "easy"
      sleep 1
      puts "Oh wait... you are on easy... ouch\n\n"
      sleep 1
    end
  end
end


# Initialize board and select difficulty
system 'clear'
difficulty = select_difficulty
current_board = initialize_board
square_index = %w(1 2 3 4 5 6 7 8 9)
winner = nil
system 'clear'
update_board(current_board, square_index)

# Main loop
loop do
  loop do
    # User selects square
    user_spot = gets.chomp

    # Check validity of choice
    if square_index.include?(user_spot)
      square_index[user_spot.to_i - 1] = " "
      current_board[user_spot.to_i] = :x
      break
    else
      system 'clear'
      update_board(current_board, square_index)
      puts (1..9).include?(user_spot.to_i) ? "\nThat square has been taken. Please select another square" :\
                                             "\nThat is not a valid selection. Please select a number between 1 and 9."
      next
    end
  end
  
  # Update main board
  system 'clear'
  update_board(current_board, square_index)

  # Check if user won
  winner = :user if check_winner(current_board, :x)
  break if winner

  # Check for tie
  break if current_board.select {|num, sq| sq == :b}.empty?

  # Computer selects spot
  computer_spot = difficulty == "hard" ? advanced_computer_spot_selection(current_board) : nil
  computer_spot ||= square_index.select { |sq| sq != ' ' }.sample
  
  # Update with computer selection
  square_index[computer_spot.to_i - 1] = " "
  current_board[computer_spot.to_i] = :o
  sleep 1
  system 'clear'
  update_board(current_board, square_index)

  # Check if computer won
  winner = :computer if check_winner(current_board, :o)
  break if winner
end

display_winner_message(winner, difficulty)
