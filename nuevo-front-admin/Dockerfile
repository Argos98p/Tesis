# ==== CONFIGURE =====
# Use a Node 16 base image
FROM node:18-alpine  as builder
# Set the working directory to /app inside the container
WORKDIR /app
# Copy app files
COPY . .
# ==== BUILD =====
# Install dependencies (npm ci makes sure the exact versions in the lockfile gets installed)
RUN npm ci --legacy-peer-deps
# Build the app
RUN npm run build
# ==== RUN =======
# Set the env to "production"
#ENV NODE_ENV production
# Expose the port on which the app will be running (3000 is the default that `serve` uses)
#EXPOSE 3000
# Start the app

#FROM nginx:1.19.0
#WORKDIR /usr/share/nginx/html
#RUN rm -rf ./*
#COPY --from=builder /app/build .
#ENTRYPOINT [ "nginx" ,"-g", "daemon off;" ]
CMD [ "npm", "start"]