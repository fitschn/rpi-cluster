FROM python:3.9-bullseye

RUN python -m pip install rpi.gpio

RUN mkdir -p /opt/gas-meter

COPY gas_meter.py /opt/gas-meter/gas_meter.py
COPY gas_counter.txt /opt/gas-meter/gas_counter.txt

WORKDIR /opt/gas-meter

ENTRYPOINT ["python3 gas_meter.py"]
