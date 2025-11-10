FROM bitnami/testlink:latest

# Optional: make sure the container listens on port 80 for Render
EXPOSE 80

# Render uses the PORT env var automatically; Bitnami already runs Apache.
CMD ["/opt/bitnami/scripts/testlink/run.sh"]