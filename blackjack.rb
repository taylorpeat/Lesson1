CARD_FORMAT = [" _________ ", "|%{num}%{n10}%{c8}   %{c8}  |", "|%{suit} %{c6} %{c10} %{c6}  |",
               "|  %{c4} %{c7} %{c4}  |", "|  %{c6} %{c9} %{c6}  |", "|  %{c4} %{c2} %{c4}  |",
               "|  %{c6} %{c10} %{c6} %{suit}|", "|  %{c8}   %{c8}%{n10}%{num}|", " --------- "]
SUITS = %i(spades clubs hearts diamonds)
VALUES = [["2", 2], ["3", 3], ["4", 4], ["5", 5], ["6", 6], ["7", 7], ["8", 8], ["9", 9],
          ["10", 10], ["jack", 10], ["queen", 10], ["king", 10], ["ace", 11]]

def initialize_deck
  deck = SUITS.product(VALUES).each { |card| card.flatten! }
  deck = shuffle_deck(deck)
end

def initialize_variables
  player_total = player_total2 = dealer_total = bet = bet2 = 0
  player_cards = player_cards2 = dealer_cards = []
  stand = stand2 = continue = false
  deck = initialize_deck
  [deck, player_cards, player_cards2, dealer_cards, player_total, player_total2, dealer_total, bet, bet2, stand, stand2, continue]
end

def shuffle_deck(deck)
  shuffled_deck = []
  loop do
    next_card = rand(deck.length)
    shuffled_deck << deck.delete_at(next_card)
    break if deck.length < 1
  end
  shuffled_deck
end

def update_card_values(card)
  c2 = c4 = c6 = c7 = c8 = c9 = c10 = n10 = " "
  num = card[1]
  case card[0]
  when :spades then suit = "\u2660"
  when :clubs then suit = "\u2663"
  when :hearts then suit = "\u2665"
  when :diamonds then suit = "\u2666"
  end
  case card[1]
  when "2" then c2 = c7 = suit
  when "3" then c9 = c10 = suit
  when "4" then c4 = suit
  when "5" then c4 = c9 = suit
  when "6" then c6 = suit
  when "7" then c6 = c7 = suit
  when "8" then c4 = c8 = suit
  when "9" then c4 = c8 = c9 = suit
  when "10"
    c4 = c8 = c10 = suit
    n10 = ""
  when "ace"
    num = "A"
    c9 = suit
  when "king"
    num = "K"
    c9 = suit
  when "queen"
    num = "Q"
    c9 = suit
  when "jack"
    num = "J"
    c9 = suit
  end
  [suit, num, c2, c4, c6, c7, c8, c9, c10, n10]
end

def compile_lines(lines, cv)
  lines[0] << CARD_FORMAT[0]
  lines[1] << format(CARD_FORMAT[1], num: cv[1], c8: cv[6], n10: cv[9])
  lines[2] << format(CARD_FORMAT[2], suit: cv[0], c6: cv[4], c10: cv[8])
  lines[3] << format(CARD_FORMAT[3], c4: cv[3], c7: cv[5])
  lines[4] << format(CARD_FORMAT[4], c6: cv[4], c9: cv[7])
  lines[5] << format(CARD_FORMAT[5], c2: cv[2], c4: cv[3])
  lines[6] << format(CARD_FORMAT[6], suit: cv[0], c6: cv[4], c10: cv[8])
  lines[7] << format(CARD_FORMAT[7], num: cv[1], c8: cv[6], n10: cv[9])
  lines[8] << CARD_FORMAT[8]
end

def compile_lines_hidden(lines, cv)
  lines[0] << CARD_FORMAT[0].slice(0..2)
  lines[1] << format(CARD_FORMAT[1], num: cv[1], c8: cv[6], n10: cv[9]).slice(0..2)
  lines[2] << format(CARD_FORMAT[2], suit: cv[0], c6: cv[4], c10: cv[8]).slice(0..2)
  lines[3] << format(CARD_FORMAT[3], c4: cv[3], c7: cv[5]).slice(0..2)
  lines[4] << format(CARD_FORMAT[4], c6: cv[4], c9: cv[7]).slice(0..2)
  lines[5] << format(CARD_FORMAT[5], c2: cv[2], c4: cv[3]).slice(0..2)
  lines[6] << format(CARD_FORMAT[6], suit: cv[0], c6: cv[4], c10: cv[8]).slice(0..2)
  lines[7] << format(CARD_FORMAT[7], num: cv[1], c8: cv[6], n10: cv[9]).slice(0..2)
  lines[8] << CARD_FORMAT[8].slice(0..2)
end

def update_display(name, balance, player_cards, player_cards2, dealer_cards, player_total, player_total2,
                   dealer_total, stand, stand2, bet ,bet2)
  if stand && (stand2 || player_total2 == 0) && !player_doesnt_care?(player_total, player_total2, dealer_total)
    sleep 1
  else
    dealer_total = dealer_cards[0][2] unless dealer_cards.empty?
    dealer_cards =  dealer_cards.take(1) unless dealer_cards.empty?
  end
  system 'clear'
  puts "Balance: $#{balance}" + " " * 10 + "--TEALEAF BLACKJACK--"
  puts "Wager: $#{bet + bet2}"
  puts "\nPlayer Cards:" + " " * 25 + "Dealer Cards:"
  display_cards(player_cards, dealer_cards)
  print player_cards.empty? ? "" : "Player total:#{player_total}"
  print player_total < 10 ? " " * 24 : " " * 23
  puts "Dealer total:#{dealer_total}"
  display_cards(player_cards2, []) unless player_cards2.empty?
  puts "Second hand total: #{player_total2}" if player_total2 > 0
  puts
end

def display_cards(player_cards, dealer_cards)
  lines = ["","","","","","","","",""]
  player_cards.each_with_index do |card, idx|
    card_values = update_card_values(card)
    idx < player_cards.length - 2 ? compile_lines_hidden(lines, card_values) : compile_lines(lines, card_values)  
  end
  lines.each { |line| line << " " * (16 - ((player_cards.length - 2) * 3)) }
  lines.each { |line| line << " " * 8 } if player_cards.length == 1
  dealer_cards.each_with_index do |card, idx|
    card_values = update_card_values(card)
    idx < dealer_cards.length - 2 ? compile_lines_hidden(lines, card_values) : compile_lines(lines, card_values)
  end
  lines.each { |line| puts line }
end

def initial_prompt(balance)
  system 'clear'
  puts "Balance: $#{balance}" + " " * 9 + "--TEALEAF BLACKJACK--"
  print "\nHow much would you like to wager: "
  bet = gets.chomp.to_i
  loop do
    if (1..balance.to_i).include?(bet)
      break
    elsif bet > balance
      print "Your wager exceeds your balance. Please re-enter a valid wager: "
    else
      print "Please re-enter a valid wager: "
    end
    bet = gets.chomp.to_i
  end
  [bet, balance -= bet]
end

def determine_plays(player_cards, player_cards2, balance, bet)
  valid_plays = %w(Hit Stand)
  if player_cards2.empty?
    valid_plays << "Split" if player_cards.length == 2 \
                              && player_cards[0][2] == player_cards[1][2] && balance > bet
    valid_plays << "Double" if player_cards.length == 2 && balance > bet
  end
  valid_plays
end

def deal_cards(deck)
  player_cards = [deck[0], deck[2]]
  dealer_cards = [deck[1], deck[3]]
  deck.shift(4)
  player_cards, player_total = determine_hand_values(player_cards)
  dealer_cards, dealer_total = determine_hand_values(dealer_cards)
  [player_cards, dealer_cards, player_total, dealer_total]
end

def determine_hand_values(cards)
  total = cards[0][2] + cards[1][2]
  if total == 22
    total = 12
    cards[1][2] = 1
  end
  [cards, total]
end

def update_hand(deck, name, balance, player_cards, player_cards2, dealer_cards, player_total, player_total2,
                     dealer_total, stand, stand2, bet, bet2)
  play = prompt_user(player_cards, player_cards2, balance, bet)
  case play
  when "Hit" then deck, player_cards, player_total = hit(deck, player_cards, player_total)
  when "Double"
    balance -= bet
    bet *= 2
    deck, player_cards, player_total = hit(deck, player_cards, player_total)
    stand = true
  when "Split"
    balance -= bet
    bet2 = bet
    player_cards2[0] = player_cards[1]
    player_cards.delete_at(1)
    player_total = player_cards[0][2]
    player_total2 = player_cards2[0][2]
  when "Stand" then stand = true
  end
  update_display(name, balance, player_cards, player_cards2, dealer_cards, player_total, player_total2,
                     dealer_total, stand, stand2, bet, bet2)
  [deck, player_cards, player_cards2, player_total, player_total2, balance, bet, bet2, stand]
end

def prompt_user(player_cards, player_cards2, balance, bet)
  valid_plays = determine_plays(player_cards, player_cards2, balance, bet)
  print "\nPlease select an option: "
  valid_plays.each {|play| print play + " " }
  puts
  play = gets.chomp
  loop do
    if valid_plays.include?(play.capitalize)
      return play.capitalize
    else
      print "\nThat is not a valid option. Please re-enter your selection: "
      play = gets.chomp
    end
  end
end

def hit(deck, player_cards, player_total)
  player_cards << deck[0]
  player_total += player_cards.last[2]
  if player_total > 21
    if player_cards.any? { |card| card[2] == 11}
      player_total -= 10 
      player_cards.select { |card| card[2] == 11 }.first[2] = 1
    end
  end
  deck.shift
  [deck, player_cards, player_total]
end

def winning_message(player_total, player_total2, dealer_total, bet, bet2, balance, name)
  bet, bonus = decide_winner(player_total, player_total2, dealer_total, bet, name, "first")
  unless player_total2 == 0
    sleep 1
    puts
    bet2, bonus2 = decide_winner(player_total2, 1, dealer_total, bet2, name, "second")
  end
  bonus ||= 0
  bonus2 ||= 0
  balance += (bet * 2 + bet2 * 2 + bonus + bonus2).to_i
  puts "\nYour new balance is $#{balance}."
  balance
end

def decide_winner(player_total, player_total2, dealer_total, bet, name, hand_num)
  if dealer_total == 21 && player_total != 21
    puts "The dealer hit blackjack! You lost $#{bet}."
    bet = 0
  elsif
    player_total > 21
    print "You busted and lost $#{bet}"
    puts player_total2 == 0 ? "." : " on your #{hand_num} hand."
    bet = 0
  elsif player_total == 21
    bonus = bet / 2
    print "Congratulations #{name}! You got blackjack"
    puts player_total2 == 0 ? "!!" : " on your #{hand_num} hand!!"
    puts "You won $#{bet + bonus}."
  elsif player_total > dealer_total
    print "Congratulations #{name}! You beat the dealer #{player_total} to #{dealer_total}"
    puts player_total2 == 0 ? "." : " on your #{hand_num} hand."
    puts "You won $#{bet}."
  elsif player_total < dealer_total && dealer_total <= 21
    print "Sorry. You lost to the dealer #{dealer_total} to #{player_total}"
    puts player_total2 == 0 ? "." : " on your #{hand_num} hand."
    puts "You lost $#{bet}."
    bet = 0
  elsif player_total == dealer_total
    print "It's a push. You tied the dealer with #{player_total}"
    puts player_total2 == 0 ? "." : " on your #{hand_num} hand."
    bet = bet / 2.0
  elsif dealer_total > 21
    print "The dealer busted! You won $#{bet}"
    puts player_total2 == 0 ? "." : " on your #{hand_num} hand."
  end
  [bet, bonus]
end

def player_doesnt_care?(player_total, player_total2, dealer_total)
  player_total >= 21 && (player_total2 == 0 || player_total2 >= 21)
end

def prompt_continue?(name)
  puts "\n#{name}, would you like to continue playing? (y/n)"
  continue = gets.chomp.downcase
  i = 0
  loop do
    break if %w(y n).include?(continue) || i > 2
    puts "That is not a valid selection. Would you like to continue? (y/n)"
    continue = gets.chomp.downcase
    i += 1
  end
  continue
end

def final_message(balance, stand, stand2, player_total2)
  puts "\nYou have lost all of your money." if balance == 0 && stand && (stand2 || player_total2 == 0)
  if balance >= 1000 && stand && (stand2 || player_total2 == 0)
    puts "\nYour balance has reached $1000! You have been banned from Tealeaf Casinos."
  end
  puts "Goodbye.\n\n\n"
end


# Set initial variable scope outside main loop
deck = initialize_deck
balance = 100
continue = "y"
player_total = player_total2 = dealer_total = bet = bet2 = 0
player_cards = player_cards2 = dealer_cards = []
stand = stand2 = continue = false

# Welcome user
system 'clear'
puts "Welcome to Tealeaf Blackjack"
print "\nPlease enter your name: "
name = gets.chomp.capitalize
puts "\n#{name}, your starting balance is $100."
puts "\nPress ENTER to begin playing."
gets


# Main loop
loop do
  # Initialize variables
  if continue == "y"
  deck, player_cards, player_cards2, dealer_cards, player_total, player_total2, dealer_total, bet, bet2, stand,
  stand2, continue = initialize_variables
  end

  # User input and update hands
  ## Initial input
  if player_cards.empty?
    bet, balance = initial_prompt(balance)
    player_cards, dealer_cards, player_total, dealer_total = deal_cards(deck)
    update_display(name, balance, player_cards, player_cards2, dealer_cards, player_total, player_total2,
                   dealer_total, stand, stand2, bet, bet2)
  else
    ## First hand input and update
    unless stand
      print "(For first hand)" unless player_total2 == 0
      deck, player_cards, player_cards2, player_total, player_total2, balance, bet, bet2, stand \
        = update_hand(deck, name, balance, player_cards, player_cards2, dealer_cards, player_total, player_total2,
                     dealer_total, stand, stand2, bet, bet2)
    end
    ## Second hand input and update
    if player_cards2.length > 1 && !stand2
      print "(For second hand)"
      deck, player_cards2, player_cards, player_total2, player_total, balance, bet, bet2, stand2 \
        = update_hand(deck, name, balance, player_cards, player_cards2, dealer_cards, player_total, player_total2,
                     dealer_total, stand, stand2, bet, bet2)
    end
    ## Update after split
    if player_cards2.length == 1
      update_display(name, balance, player_cards, player_cards2, dealer_cards, player_total, player_total2,
                     dealer_total, stand, stand2, bet, bet2)
      deck, player_cards, player_total = hit(deck, player_cards, player_total)
      deck, player_cards2, player_total2 = hit(deck, player_cards2, player_total2)
      sleep 1
      update_display(name, balance, player_cards, player_cards2, dealer_cards, player_total, player_total2,
                     dealer_total, stand, stand2, bet, bet2)
    end
  end

  # Check for bust, win, blackjack and dealer blackjack
  stand = true if dealer_total == 21 || player_total > 21 || player_total == 21
  stand2 = true if player_total2 > 21 || player_total2 == 21

  # Computer's turn
  if stand && (player_cards2.empty? || stand2 )
    loop do
      break if dealer_total >= 17 || player_doesnt_care?(player_total, player_total2, dealer_total)
      deck, dealer_cards, dealer_total = hit(deck, dealer_cards, dealer_total)
      update_display(name, balance, player_cards, player_cards2, dealer_cards, player_total, player_total2,
                     dealer_total, stand, stand2, bet, bet2)
    end
  end

  # Print winning message / decide if dealer needs to show second card
  if stand && (stand2 || player_total2 == 0)
    dealer_total = dealer_cards[0][2] if player_doesnt_care?(player_total, player_total2, dealer_total)
    update_display(name, balance, player_cards, player_cards2, dealer_cards, player_total, player_total2,
                   dealer_total, stand, stand2, bet, bet2)
    balance = winning_message(player_total, player_total2, dealer_total, bet, bet2, balance, name)
    sleep 1
    continue = (1..999).include?(balance) ? prompt_continue?(name) : false
  end
  break if continue == 'n' || !(1..999).include?(balance) && stand && (stand2 || player_total2 == 0)
end

final_message(balance, stand, stand2, player_total2)

