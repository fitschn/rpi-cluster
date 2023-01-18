import RPi.GPIO as GPIO
import time
import logging

# Configure logging
logging.basicConfig(format="%(asctime)s: [%(levelname)s] %(message)s", level=logging.INFO)

# General GPIO configuration
GPIO.setmode(GPIO.BOARD)
GPIO.setwarnings(False)

# Configure input of our reed sensor (connected to PIN 21)
pin_reed_sensor = 21
GPIO.setup(pin_reed_sensor, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# Get start value
file_c = open("gas_counter.txt", "r")
gas_counter = float(file_c.read())
file_c.close()

# Initialize status_old
status_old = 1

while True:
    status_new = GPIO.input(pin_reed_sensor)

    # Reed contact is open
    if status_new == 1:
        logging.debug("contact open")
        status_old = status_new

    # Reed contact is closed (new full rotation detected)
    elif status_new == 0:
        logging.debug("contact closed")

        # Increase value only when we switch from open to closed
        # Do nothing, if the previous status was already closed
        if status_old != status_new:
            gas_counter = round(gas_counter + 0.01, 2)
            logging.info(f"Gas counter increased. New value is {gas_counter}")
            status_old = status_new
            # Write new value to file
            file_c = open("gas_counter.txt", "w")
            file_c.write(str(gas_counter))
            file_c.close()

    time.sleep(1)
