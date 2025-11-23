require("dotenv").config({ path: ".env.test" });

const connectDB = require("./src/database");
const setupTestUser = require("./tests/setupTestUser");
const setupTestSpace = require("./tests/setupTestSpace");

beforeAll(async () => {
  await connectDB();
  await setupTestUser();
  await setupTestSpace();
});

afterAll(async () => {
  const mongoose = require("mongoose");
  await mongoose.connection.close();
});
