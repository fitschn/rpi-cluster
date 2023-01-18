FROM python:3.9-bullseye

RUN apt-get update && apt-get install -y python3-rpi.gpio && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/gas-meter

COPY gas_meter.py /opt/gas-meter/gas_meter.py
COPY gas_counter.txt /opt/gas-meter/gas_counter.txt

WORKDIR /opt/gas-meter

ENTRYPOINT ["python3 gas-meter.py"]
