import { defineConfig } from "@playwright/test";

// The reporter here is deliberately NOT html: the reusable workflow replaces
// config reporters with its own single --reporter flag (lgtm-hq/lgtm-ci#804),
// so the HTML report must come from the workflow, not from this file.
export default defineConfig({
  testDir: "tests",
  reporter: process.env.CI ? "json" : "list",
  projects: [
    // Default project: every passing test. run-playwright's --project=chromium
    // and playwright.yml's `project: chromium` both land here.
    { name: "chromium", use: { browserName: "chromium" }, testIgnore: /failing\.spec\.js/ },
    // Negative project: one test that always fails, selected only by
    // playwright-negative.yml to exercise the failure-path report upload.
    { name: "chromium-failing", use: { browserName: "chromium" }, testMatch: /failing\.spec\.js/ },
  ],
});
