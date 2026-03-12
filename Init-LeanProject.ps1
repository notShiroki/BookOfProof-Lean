param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory = $true)]
    [string]$VaultTargetFolder
)

Write-Host "Initializing Lean 4 Mathlib project: $ProjectName..."

# 1. Initialize Lean project in the current directory
# (Using 'lake init' instead of 'lake new' so it initializes in the current cloned directory)
lake init $ProjectName math

# 2. Setup Obsidian notes folder structure inside the Lean repo
$obsidianRoot = "obsidian"
$notesFolder = Join-Path $obsidianRoot $VaultTargetFolder

Write-Host "Creating Obsidian notes folder: $notesFolder"
New-Item -ItemType Directory -Force -Path $notesFolder | Out-Null

# 3. Create a starter Markdown note
$readmePath = Join-Path $notesFolder "00_Index.md"
@"
---
tags: [lean4, math, $ProjectName]
source_repo: "$ProjectName"
---
# $ProjectName Index

This folder contains informal mathematics notes and Lean 4 formalization proofs.
It is automatically synced to the main Obsidian vault under `math/$VaultTargetFolder/`.
"@ | Out-File -Encoding UTF8 $readmePath

# 4. Append Obsidian exclusions to .gitignore
$gitignorePath = ".gitignore"
$gitignoreContent = @"

# Obsidian workspace/cache
.obsidian/workspace
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/cache/
.obsidian/backlink-cache.json
.DS_Store
"@

if (Test-Path $gitignorePath) {
    $gitignoreContent | Add-Content $gitignorePath
    Write-Host "Appended Obsidian patterns to .gitignore"
} else {
    $gitignoreContent | Out-File -Encoding UTF8 $gitignorePath
    Write-Host "Created .gitignore with Obsidian patterns"
}

# 5. Download Mathlib cache so you don't compile from scratch
Write-Host "Downloading Mathlib precompiled binaries..."
lake exe cache get

Write-Host "Initialization complete. Run 'git add .' to stage the setup."
