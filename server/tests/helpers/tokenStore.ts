// Token store for sharing authentication tokens across test suites
export const tokenStore: {
  [key: string]: string;
} = {};

export const idStore: {
  [key: string]: string;
} = {};

export function setToken(key: string, token: string): void {
  tokenStore[key] = token;
}

export function getToken(key: string): string {
  return tokenStore[key];
}

export function setId(key: string, id: string): void {
  idStore[key] = id;
}

export function getId(key: string): string {
  return idStore[key];
}

export function clearStore(): void {
  Object.keys(tokenStore).forEach((key) => delete tokenStore[key]);
  Object.keys(idStore).forEach((key) => delete idStore[key]);
}

