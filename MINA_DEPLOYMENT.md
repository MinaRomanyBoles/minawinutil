# Mina WinUtil — build and domain deployment

Source repository: https://github.com/MinaRomanyBoles/minawinutil  
Based on the MIT-licensed https://github.com/ChrisTitusTech/winutil (see `LICENSE`).

## Architecture

1. Edit the fork's source code on a feature branch; do not hand-edit the generated `winutil.ps1`.
2. Review and merge the changes into `main` after a successful Windows GitHub Actions compile check.
3. The `Build & Publish Mina WinUtil` workflow builds `winutil.ps1`, checks PowerShell syntax, prepends the MIT license and publishes the file to this repository's **dist** branch.
4. The separate Vercel portfolio project rewrites `/win` to:
   `https://raw.githubusercontent.com/MinaRomanyBoles/minawinutil/dist/winutil.ps1`.
5. After deployment and verification, run in **Windows PowerShell (Administrator)**:
   ```powershell
   irm https://minaromany.online/win | iex
   ```

## Verification before executing remote code

```powershell
$source = 'https://minaromany.online/win'
$r = Invoke-WebRequest -Uri $source -UseBasicParsing
$r.StatusCode
$r.Headers['Content-Type']
$r.Content.Substring(0, [Math]::Min(150, $r.Content.Length))
```

It must be a successful response containing PowerShell source (beginning with the MIT license comment), **not** the site's HTML homepage.

To inspect without executing:
```powershell
Invoke-WebRequest -Uri 'https://minaromany.online/win' -OutFile '.\mina-winutil.ps1'
Get-FileHash .\mina-winutil.ps1 -Algorithm SHA256
```

Review the downloaded file before invoking it with administrator privileges.

## Important operating constraints

- The upstream URL `https://christitus.com/win` still loads the upstream project's build.
- Keep the MIT copyright and permission notice in every redistributed compiled script.
- The `dist` branch is **generated output**; do not edit it manually. Its history is replaced on each successful publish.
- The Vercel rewrite must come *before* the portfolio SPA catch-all rewrite.
- GitHub Actions must have **Read and write permissions** to repository contents (the workflow requests `contents: write`; repository or organization restrictions may still override this).
- This fork inherits upstream code, functions, links and dependencies. Modifying the launch URL does **not** make every dependency independent.
- Windows 10 is not actively supported by the current upstream WinUtil; use caution and test before deploying to managed school/domain PCs.
- A GitHub Actions build proves syntax/package success, not full WPF/Windows functional correctness. Test in a Windows VM before distributing.
