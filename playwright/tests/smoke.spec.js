import { expect, test } from "@playwright/test";

test("renders inline content", async ({ page }) => {
  await page.setContent("<h1>lgtm-ci consumer fixture</h1>");
  await expect(page.getByRole("heading")).toHaveText("lgtm-ci consumer fixture");
});
