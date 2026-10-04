import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "tests",
  reporter: process.env.CI ? "json" : "list",
  projects: [{ name: "chromium", use: { browserName: "chromium" } }],
});
