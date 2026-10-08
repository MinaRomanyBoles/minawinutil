// Build two distinct, embedded WPF images:
// - Mina's original SVG -> window/nav icon (unchanged)
// - Supplied portrait PNG -> large developer-card profile image
// Both are embedded at compile time, so the executable is self-contained.
const fs = require('node:fs/promises');
const path = require('node:path');
const sharp = require('sharp');

async function download(url, kind) {
  const response = await fetch(url, {
    signal: AbortSignal.timeout(60000),
    headers: {
      'User-Agent': 'Mozilla/5.0 (compatible; MinaWinUtil-Build/1.0)',
      'Accept': kind === 'svg' ? 'image/svg+xml,image/*' : 'image/png,image/*',
    },
  });
  if (!response.ok) throw new Error(`Failed to fetch ${kind} asset (${response.status}): ${url}`);
  const data = Buffer.from(await response.arrayBuffer());
  if (data.length < 100 || data.length > 5_000_000) {
    throw new Error(`Unexpected ${kind} asset size (${data.length})`);
  }
  if (kind === 'svg' && !data.toString('utf8', 0, 1200).includes('<svg')) {
    throw new Error('Original logo URL did not return SVG');
  }
  if (kind === 'png' && !data.subarray(0, 8).equals(
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])
  )) {
    throw new Error('New profile URL did not return a PNG file');
  }
  return data;
}

(async () => {
  const logoBytes = await download('https://minaromany.online/mina.svg', 'svg');
  const logoPath = path.join(__dirname, 'mina-profile.png');
  await sharp(logoBytes, { density: 144 })
    .resize(256, 256, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png({ compressionLevel: 9 })
    .toFile(logoPath);

  const portraitBytes = await download('https://a.top4top.io/p_39336kl2l1.png', 'png');
  const portraitPath = path.join(__dirname, 'mina-portrait.png');
  // Cover crops empty margins rather than shrinking the actual face.
  await sharp(portraitBytes)
    .rotate()
    .resize(440, 440, { fit: 'cover', position: 'attention' })
    .png({ compressionLevel: 9 })
    .toFile(portraitPath);

  for (const file of [logoPath, portraitPath]) {
    const bytes = (await fs.stat(file)).size;
    if (bytes < 1000) throw new Error(`Rendered PNG is unexpectedly small: ${file}`);
    console.log(`Built WPF asset: ${path.basename(file)} (${bytes} bytes)`);
  }
})().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
