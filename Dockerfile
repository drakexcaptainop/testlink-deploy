FROM techknowlogick/testlink:latest

# Tell Render that this container exposes port 80
EXPOSE 80

# Default command that runs Apache inside the image
CMD ["apache2-foreground"]