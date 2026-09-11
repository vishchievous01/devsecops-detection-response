FROM python:3.12-slim

WORKDIR /app

COPY receiver.py /app/receiver.py

USER 999:999

EXPOSE 8080

CMD ["python3", "/app/receiver.py"]
