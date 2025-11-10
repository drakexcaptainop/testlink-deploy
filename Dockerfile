FROM lscr.io/linuxserver/testlink:latest

# Render expects the app to listen on $PORT
# This image exposes port 80 by default, so just map it
EXPOSE 80

# Ensure Apache runs when Render starts
CMD ["/init"]