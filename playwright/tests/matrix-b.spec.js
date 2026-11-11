import { expect, test } from "@playwright/test";

// One @smoke test per file: e2e-matrix.yml runs two shards and Playwright
// splits shards by file, so each shard gets exactly one test.
test("matrix shard file b renders @smoke", async ({ page }) => {
  await page.setContent("<h1>shard b</h1>");
  await expect(page.getByRole("heading")).toHaveText("shard b");
});
