import { expect, test } from "@playwright/test";

// Only runs under the `chromium-failing` project (playwright-negative.yml).
test("fails on purpose", async ({ page }) => {
  await page.setContent("<h1>lgtm-ci consumer fixture</h1>");
  await expect(page.getByRole("heading")).toHaveText("not this text", { timeout: 500 });
});
