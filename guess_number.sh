# Author: Riccardo Ciucci
echo "Welcome, you'll have to guess a number with a limited amount of tries"
total_guesses=3
while true;
do
    # Generate the number and start the match
    number=$(($RANDOM%10+1))
    # echo $number
    guesses_left=$total_guesses
    echo "You have $guesses_left guesses to find the number..."

    # Do the guessing
    while [ $guesses_left -gt 0 ]
    do
        echo -n "You still have $guesses_left/$total_guesses guesses: "
        read guess
        if [ $guess -eq $number ]
        then
            break
        fi
        ((guesses_left--))
    done

    # See the results
    if [ $guesses_left -eq 0 ]
    then
        echo "You ran out of guesses..."
        echo "Maybe you'll be luckier next time!"
    else
        echo "You found the number!"
    fi
    
    # We ask if the user wants to exit
    echo -n "Do you wish to exit? (type 'y' to exit): "
    read -n1 choice
    echo
    if [[ "$choice" =~ [Yy] ]]
    then
        echo "See you!"
        break
    fi    

    # Game resets itself
    echo 
    echo
    echo "The number will be regenerated and the guesses restored."
done