#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

display_services() {
  echo -e "\n~~~~ MY SALON ~~~~\n"
  echo -e "Welcome to My Salon, how can I help you?\n"

  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS="|" read service_id name
  do 
      echo "$service_id) $name"
  done
}

# Keep asking until a valid service is selected
while true; do
  display_services
  read  SERVICE_ID_SELECTED

  VALID_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -n $VALID_SERVICE ]]; then
    echo -e "\nYou have selected service #$SERVICE_ID_SELECTED."
    break
  else
    echo -e "\nI could not find that service. Please try again."
  fi
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]; then
  
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")


INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]; then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
else
echo -e "\nFailed to schedule the appointment. Please try again."
fi
