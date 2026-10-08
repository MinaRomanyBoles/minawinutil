// Convert Mina's original https://minaromany.online/mina.svg to PNG for WPF.
// The generated file is embedded into the compiled PowerShell script; no runtime
// browser, external image dependency, or SVG decoder is needed on users' PCs.
const fs = require('node:fs/promises');
const path = require('node:path');
const sharp = require('sharp');

(async () => {
  const source = 'https://minaromany.online/mina.svg';
  const response = await fetch(source, { signal: AbortSignal.timeout(60000) });
  if (!response.ok) throw new Error(`Cannot fetch developer photo: HTTP ${response.status}`);
  const bytes = Buffer.from(await response.arrayBuffer());
  if (bytes.length < 100 || bytes.length > 3_000_000 ||
      !bytes.toString('utf8', 0, 1000).includes('<svg')) {
    throw new Error('Developer photo is not a valid expected SVG asset');
  }
  const output = path.join(__dirname, 'mina-profile.png');
  await sharp(bytes, { density: 144 })
    .resize(256, 256, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png({ compressionLevel: 9 })
    .toFile(output);
  const size = (await fs.stat(output)).size;
  if (size < 1000) throw new Error('Rendered PNG is unexpectedly small');
  console.log(`Rendered developer image: ${output} (${size} bytes)`);
})().catch(error => { console.error(error); process.exitCode = 1; });
