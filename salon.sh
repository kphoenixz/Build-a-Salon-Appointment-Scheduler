#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon Services Appointment ~~~~~\n"
echo -e "\nHow may I help you?"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    SERVICE_ID=$(echo $SERVICE_ID | sed 's/ //g')
    NAME=$(echo $NAME | sed 's/ //g')
    echo "$SERVICE_ID) $NAME"
  done
  
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-5]) BOOK_AN_APPOINTMENT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

BOOK_AN_APPOINTMENT(){
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # if input is not a valid phone number
  if [[ ! $CUSTOMER_PHONE =~ ^[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]
  then 
    # send to main menu
    MAIN_MENU "That's not a valid phone number"
  else
    CUSTOMER_NAME=$($PSQL "SELECT name from customers WHERE phone = '$CUSTOMER_PHONE'" | sed 's/ //g')

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # get time for the booking
    echo -e "\nWhat's time do you want to make the appointment?"
    read SERVICE_TIME 

    # insert appointment result
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
    then
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed 's/ //g')
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
  fi
}

MAIN_MENU
