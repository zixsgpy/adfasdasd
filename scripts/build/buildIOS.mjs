/*
 * Nightcord, a Discord client mod
 * Copyright (c) 2026 Vendicated and contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import { cp, mkdir, rm } from "node:fs/promises";
import { join } from "node:path";

const iosResources = join("ios", "Nightcord", "Nightcord", "Resources");
await rm(iosResources, { recursive: true, force: true });
await mkdir(iosResources, { recursive: true });

await cp(join("dist", "browser", "browser.js"), join(iosResources, "Nightcord.js"));

for (const css of [join("dist", "Equicord.user.css"), join("dist", "browser", "extension.css")]) {
    try {
        await cp(css, join(iosResources, "Nightcord.css"));
        break;
    } catch {}
}

console.log(`Nightcord iOS resources prepared in ${iosResources}`);
