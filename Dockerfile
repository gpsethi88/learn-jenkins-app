FROM mcr.microsoft.com/playwright:v1.49.1-noble
RUN npm install serve -g
RUN npm install netlify-cli node-jq -g