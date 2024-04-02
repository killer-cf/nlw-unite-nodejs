FROM node:20 AS base

RUN npm i -g pnpm

FROM base AS dependencies

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

RUN pnpm install

FROM base AS build

WORKDIR /app

COPY . .
COPY --from=dependencies /app/node_modules ./node_modules

RUN pnpm build
RUN pnpm prune --prod

FROM node:20-alpine3.19 AS deploy

WORKDIR /app

RUN npm i -g pnpm prisma

COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./
COPY --from=build /app/prisma ./prisma

RUN pnpm prisma generate

EXPOSE 3333

CMD [ "pnpm", "start" ]