module.exports = {
  testEnvironment: "node",
  testMatch: ["<rootDir>/tests/**/*.test.js"],
  setupFilesAfterEnv: ["<rootDir>/jest.setup.js"],

  // 👇 NO PONER setupFiles AQUÍ
  testPathIgnorePatterns: ["/node_modules/"],
  testTimeout: 30000
};
