# Use official Node.js image as the base
FROM node:18-alpine AS builder

# Set working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Copy jsconfig.json for Next.js path aliases (if exists)
COPY jsconfig.json ./ 

# Install dependencies
RUN npm install

# Copy the application files
COPY . .

# Build the Next.js app
RUN npm run build

# -- Production Stage --
FROM node:18-alpine AS runner

# Set working directory
WORKDIR /app

# Copy necessary files from builder stage
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/jsconfig.json ./ 

# Set environment variable for production
ENV NODE_ENV=production

# Expose the port Next.js runs on
EXPOSE 3000

# Start the Next.js application
CMD ["node_modules/.bin/next", "start"]
