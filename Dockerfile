FROM jojomi/hugo:latest

ENV HUGO_THEME hugo-material-docs

RUN apt-get update && apt-get install -y git

RUN git clone https://github.com/Chatr-P2P/chatr.captainbern.io.git
COPY . /src
