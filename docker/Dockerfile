# Use Node.js 18 on Debian Bookworm as the base image
FROM node:18-bookworm

# Set the working directory
WORKDIR /app

# Install system dependencies for Deno installation and other utilities
RUN apt-get update && apt-get install -y curl unzip git procps && rm -rf /var/lib/apt/lists/*

# Install Deno
ENV DENO_INSTALL /opt/deno
ENV PATH $DENO_INSTALL/bin:$PATH
RUN curl -fsSL https://deno.land/x/install/install.sh | sh

# Create a non-root user and group
RUN groupadd --gid 1001 nodeuser &&     useradd --uid 1001 --gid 1001 --shell /bin/bash --create-home nodeuser

# Copy package.json and package-lock.json (if available)
COPY package.json ./
COPY package-lock.json* ./

# Install Node.js production dependencies
# Using npm ci ensures a clean install based on lock file
# --omit=dev skips development dependencies
RUN npm ci --omit=dev

# Copy the rest of the application code
# Note: This should be done *after* npm ci to leverage Docker cache for dependencies
COPY . .

# Change ownership of the app directory to the non-root user
RUN chown -R nodeuser:nodeuser /app

# Switch to the non-root user
USER nodeuser

# Expose default ports (though docker-compose will manage actual port mapping)
EXPOSE 3000
EXPOSE 3001

# Default command (will be overridden by docker-compose.yml)
# This assumes cli.js is the main entry point for claude-flow
CMD ["node", "./cli.js", "start"]
