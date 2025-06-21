# Use Node.js 18 on Debian Bookworm as the base image
FROM node:18-bookworm

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y curl unzip git procps python3 make g++ && rm -rf /var/lib/apt/lists/*

# Install Deno
ENV DENO_INSTALL /opt/deno
ENV PATH $DENO_INSTALL/bin:$PATH
RUN curl -fsSL https://deno.land/x/install/install.sh | sh

# Create a non-root user and group
RUN groupadd --gid 1001 nodeuser && \
  useradd --uid 1001 --gid 1001 --shell /bin/bash --create-home nodeuser

# Copy all source files first.
COPY . .

# DEBUG: List contents of /app and /app/scripts to see if install.js is there
RUN echo "Listing /app contents:" && find /app -maxdepth 1 -ls
RUN echo "Listing /app/scripts contents:" && find /app/scripts -maxdepth 1 -ls

# Install Node.js dependencies
RUN npm ci

# Run the TypeScript build
RUN npm run build:ts

# Optional: Prune devDependencies after build
# RUN npm prune --production

# Change ownership
RUN chown -R nodeuser:nodeuser /app

# Switch to non-root user
USER nodeuser

EXPOSE 3000
EXPOSE 3001

CMD ["node", "./cli.js", "start"]
