FROM jojomi/hugo:latest

ENV HUGO_THEME hugo-material-docs
RUN git clone https://github.com/Chatr-P2P/chatr.captainbern.io.git
COPY . /src
