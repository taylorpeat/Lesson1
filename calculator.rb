def request(question)
  puts question
  gets.chomp
end

num1 = request("What's the first number?")
num2 = request("What's the second number?")
operator = request("Select an operator: 1) Add, 2) Subtract, 3) Multiply, 4) Divide")

case operator
when '1' then result = num1.to_i + num2.to_i
when '2' then result = num1.to_i - num2.to_i
when '3' then result = num1.to_i * num2.to_i
when '4' then result = num1.to_i / num2.to_i
else result = "Invalid selection."
end

puts "The answer is: #{result}"

