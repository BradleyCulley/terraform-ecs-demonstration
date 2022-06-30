FROM node:16.13.0

# Working area
WORKDIR /app

# Copy over all the config, install, build to image
COPY . /app

# RUN npm ci --production && npm run build
RUN npm ci --production

# todo implement this as port 443, once things are working at basic level in ECS
ENV CUSTOM_NODE_PORT=3000

# Start the node server
CMD ["npm","run","ecs"]
