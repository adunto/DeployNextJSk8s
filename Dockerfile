# Stage 1: 기본 Node.js 환경 및 의존성 정의 (스테이지 이름: 'build')
FROM node:22.16-alpine AS build
WORKDIR /app
COPY package*.json ./
# 'build' 스테이지에서 EXPOSE는 보통 필요 없지만, 원래 파일에 있어 유지합니다.
# 프로덕션/개발 스테이지에서 명시하는 것이 더 일반적입니다.
# EXPOSE 3000 # 이 줄은 production/dev 스테이지로 옮기는 것이 좋습니다.

# Stage 2: 애플리케이션 빌드 (스테이지 이름: 'builder')
# 'build' 스테이지를 기반으로 합니다.
FROM build AS builder
WORKDIR /app
# package*.json은 'build' 스테이지에서 이미 복사되었습니다.
# WORKDIR이 동일하므로 해당 파일들이 이미 존재합니다.
# 전체 소스 코드를 복사하기 전에 의존성을 설치하여 Docker 레이어 캐싱을 활용합니다.
# 또는 npm ci (빌드에 필요한 모든 의존성 설치)
RUN npm ci
COPY . .
RUN npm run build

# Stage 3: 프로덕션 환경 (스테이지 이름: 'production')
# 'build' 스테이지를 기반으로 합니다. (Node.js 환경을 가져옴)
FROM build AS production
WORKDIR /app

ENV NODE_ENV=production
# 프로덕션 의존성만 설치합니다. package*.json은 'build' 스테이지로부터 이미 존재합니다.
RUN npm ci --omit=dev

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
# USER nextjs # 파일 복사 및 권한 설정 후 사용자로 전환합니다.

COPY --from=builder /app/next.config.ts ./
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
# node_modules는 위에서 `npm ci --omit=dev`로 설치했습니다.
# package.json은 'build' 스테이지에서 가져왔습니다.
# COPY --from=builder /app/node_modules ./node_modules
# COPY --from=builder /app/package.json ./package.json

USER nextjs
# 프로덕션 환경에서 포트 노출
EXPOSE 3000
# CMD는 JSON 배열 형식을 권장합니다.
CMD ["npm", "start"] 

# Stage 4: 개발 환경 (스테이지 이름: 'dev')
# 'build' 스테이지를 기반으로 합니다.
FROM build AS dev
WORKDIR /app # WORKDIR은 상속되지만, 명시적으로 작성하는 것이 좋습니다.
ENV NODE_ENV=development
# 'build' 스테이지에서 package*.json이 복사되었으므로, 여기서 의존성을 설치합니다.
# 개발에 필요한 모든 의존성 설치
RUN npm ci
# 나머지 소스 코드 복사
COPY . . 
# 개발 환경에서 포트 노출
EXPOSE 3000 
CMD ["npm", "run", "dev"]