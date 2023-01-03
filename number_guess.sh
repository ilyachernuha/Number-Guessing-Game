#!/bin/bash
# Number Guessing Game

PSQL="psql --username=freecodecamp --dbname=number_guess -X -t -c"

SECRET_NUMBER=$(($RANDOM % 1000 + 1))

echo -e "\nEnter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  ISERT_USER_RESUT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_INFO="$($PSQL "SELECT COUNT(*), MIN(guesses) FROM users INNER JOIN games USING(user_id) WHERE user_id='$USER_ID'")"
  echo $GAMES_INFO
  echo $GAMES_INFO | while read GAMES_PLAYED BAR BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

GUESSES=0

GUESS_MENU() {

  ((GUESSES++))

  echo -e "\n$1"
  read USER_GUESS

  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    GUESS_MENU "That is not an integer, guess again:"
  elif [[ $USER_GUESS < $SECRET_NUMBER ]]
  then
    GUESS_MENU "It's lower than that, guess again:"
  elif [[ $USER_GUESS > $SECRET_NUMBER ]]
  then
    GUESS_MENU "It's higher than that, guess again:"
  elif [[ $USER_GUESS == $SECRET_NUMBER ]]
  then
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES)")
    echo -e "\nYou guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  fi
}

GUESS_MENU "Guess the secret number between 1 and 1000:"
