#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo -e "\nClear the database\n"

echo $($PSQL "TRUNCATE games, teams")

echo -e "\nINSERT DATA TO THE DATABASE\n"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  if [[ $YEAR !=  "year" ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")

    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULTS=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")

      if [[ $INSERT_WINNER_RESULTS == "INSERT 0 1" ]]
      then
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
        
        echo -e "Inserted into teams, $WINNER."
      fi
    fi
    
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENTS_RESULTS=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")

      if [[ $INSERT_OPPONENTS_RESULTS == "INSERT 0 1" ]]
      then
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
        echo -e "Inserted into teams, $OPPONENT."
      fi
    fi

    INSERT_GAMES_RESULTS=$($PSQL "INSERT INTO games(year, winner_goals, opponent_goals, round, winner_id, opponent_id) VALUES($YEAR, $WINNER_GOALS, $OPPONENT_GOALS, '$ROUND', $WINNER_ID, $OPPONENT_ID)")

    if [[ $INSERT_GAMES_RESULTS == "INSERT 0 1" ]]
    then
      echo -e "Inserted into games, $YEAR - $ROUND | $WINNER $WINNER_GOALS : $OPPONENT_GOALS $OPPONENT."
    fi

  fi

done