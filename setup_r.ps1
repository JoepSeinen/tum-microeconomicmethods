# =============================================================================
# setup_r.ps1  -  R + VS Code + git setup voor Microeconometric Methods (TUM)
#
# Wat dit script doet:
#   1. Installeert R en Git via winget (slaat over wat er al is)
#   2. Installeert de R-packages voor de cursus + languageserver (voor VS Code)
#   3. Installeert de R-extensie in VS Code
#   4. Maakt de cursusmap met R/00_setup.R en R/_template.R + een git repository
#
# Uitvoeren (PowerShell, in de map waar dit bestand staat):
#   powershell -ExecutionPolicy Bypass -File .\setup_r.ps1
# =============================================================================

$ErrorActionPreference = "Continue"   # native tools (git, winget, R) write to stderr; we check exit codes ourselves
$CourseDir = Join-Path $HOME "TUM - MicroEconomicMethods"

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    OK: $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "    LET OP: $msg" -ForegroundColor Yellow }

function Update-PathFromRegistry {
    $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $user    = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machine;$user"
}

function Install-WithWinget($id, $name) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget niet gevonden. Installeer $name handmatig en draai dit script opnieuw."
    }
    $listed = winget list --id $id -e --accept-source-agreements 2>$null | Out-String
    if ($listed -match [regex]::Escape($id)) {
        Write-Ok "$name staat er al"
        return
    }
    Write-Host "    $name installeren (kan een paar minuten duren)..."
    winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "installatie voor alle gebruikers lukte niet (geen admin?), probeer alleen voor jou..."
        winget install --id $id -e --silent --scope user --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) { throw "$name installeren mislukt (winget exit code $LASTEXITCODE)." }
    }
    Write-Ok "$name geinstalleerd"
}

function Find-Rscript {
    $cmd = Get-Command Rscript -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $roots = @("$env:ProgramFiles\R", "$env:LOCALAPPDATA\Programs\R")
    foreach ($root in $roots) {
        if (Test-Path $root) {
            $found = Get-ChildItem $root -Directory -Filter "R-*" |
                     Sort-Object Name -Descending |
                     ForEach-Object { Join-Path $_.FullName "bin\Rscript.exe" } |
                     Where-Object { Test-Path $_ } |
                     Select-Object -First 1
            if ($found) { return $found }
        }
    }
    return $null
}

# ---- 1. R en Git -------------------------------------------------------------
Write-Step "R en Git installeren"
Install-WithWinget "RProject.R" "R"
Install-WithWinget "Git.Git" "Git"
Update-PathFromRegistry

$Rscript = Find-Rscript
if (-not $Rscript) { throw "Rscript.exe niet gevonden na installatie. Herstart PowerShell en draai het script opnieuw." }
Write-Ok "Rscript gevonden: $Rscript"

# ---- 2. R-packages -------------------------------------------------------------
Write-Step "R-packages installeren (tidyverse duurt even)"
$rCode = @'
lib <- Sys.getenv("R_LIBS_USER")
dir.create(lib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(lib, .libPaths()))
options(repos = c(CRAN = "https://cloud.r-project.org"))
pkgs <- c("languageserver", "jsonlite", "wooldridge", "tidyverse")
missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing) > 0) install.packages(missing, lib = lib)
still <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(still) > 0) stop("Niet gelukt: ", paste(still, collapse = ", "))
cat("Alle packages aanwezig:", paste(pkgs, collapse = ", "), "\n")
'@
$tmpR = Join-Path $env:TEMP "setup_r_packages.R"
Set-Content -Path $tmpR -Value $rCode -Encoding ASCII
& $Rscript $tmpR
if ($LASTEXITCODE -ne 0) { throw "R-packages installeren mislukt." }
Write-Ok "packages klaar"

# ---- 3. VS Code R-extensie --------------------------------------------------------
Write-Step "VS Code R-extensie installeren"
$code = Get-Command code -ErrorAction SilentlyContinue
if ($code) {
    code --install-extension REditorSupport.r --force | Out-Null
    Write-Ok "extensie REditorSupport.r geinstalleerd"
} else {
    Write-Warn "'code' staat niet in PATH. Installeer in VS Code zelf de extensie 'R' (REditorSupport)."
}

# ---- 4. Cursusmap + git repository ------------------------------------------------
Write-Step "Cursusmap en git repository: $CourseDir"
New-Item -ItemType Directory -Force -Path (Join-Path $CourseDir "R") | Out-Null

$setupFile = Join-Path $CourseDir "R\00_setup.R"
if (-not (Test-Path $setupFile)) {
@'
# =============================================================================
# 00_setup.R  -  Microeconometric Methods for Big Data (TUM, WiSe 26/27)
# Every tutorial script calls this at the top.
# =============================================================================

pkgs <- c(
  "wooldridge",  # textbook datasets (ceosal2, wage1, ...)
  "tidyverse"    # ggplot2, dplyr, readr, ...
)

options(repos = c(CRAN = "https://cloud.r-project.org"))  # fixed CRAN mirror, no prompt

# Install anything that's missing, then load everything
missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing) > 0) install.packages(missing)
invisible(lapply(pkgs, library, character.only = TRUE))

# Global options
options(digits = 4, scipen = 999)  # 4 significant digits, no scientific notation
set.seed(42)                       # reproducible simulations (Monte Carlo!)
'@ | Set-Content -Path $setupFile -Encoding ASCII
    Write-Ok "R/00_setup.R aangemaakt"
}

$templateFile = Join-Path $CourseDir "R\_template.R"
if (-not (Test-Path $templateFile)) {
@'
# =============================================================================
# Tutorial X  -  <topic>
# Microeconometric Methods for Big Data (TUM, WiSe 26/27)
#
# How to use: copy this file to tutorial_XX.R. Each "# ---- name ----" line is a
# section: it shows up in the VS Code outline (Ctrl+Shift+O) and you can run
# the code below it with Ctrl+Enter line by line.
# =============================================================================

if (file.exists("R/00_setup.R")) source("R/00_setup.R") else source("00_setup.R")  # works from course folder or R/ folder


# ---- Exercise 1 ----------------------------------------------------------
# Question: ...
#
# By hand:
#   ...
#
# In R:


# Answer / interpretation:
#   ...


# ---- Exercise 2 ----------------------------------------------------------
# Question: ...


# ---- Takeaways -----------------------------------------------------------
# - What did this tutorial connect to in the lecture?
# - Exam-relevant formulas / R functions to remember:
'@ | Set-Content -Path $templateFile -Encoding ASCII
    Write-Ok "R/_template.R aangemaakt"
}

$gitignore = Join-Path $CourseDir ".gitignore"
if (-not (Test-Path $gitignore)) {
@'
# R
.Rhistory
.RData
.Rproj.user/
*.Rproj

# Course PDFs (slides/tutorials) - not in the repo
*.pdf

# OS / editor
Thumbs.db
desktop.ini
.vscode/
'@ | Set-Content -Path $gitignore -Encoding ASCII
    Write-Ok ".gitignore aangemaakt"
}

Push-Location $CourseDir
try {
    if (-not (Test-Path (Join-Path $CourseDir ".git"))) {
        git init -b main | Out-Null
        Write-Ok "git repository aangemaakt"
    } else {
        Write-Ok "git repository bestond al"
    }

    # Commit needs a name/email; only set it for this repo if there is no global one
    $gName = git config --global user.name
    if (-not $gName) { git config user.name "Joep" }
    $gMail = git config --global user.email
    if (-not $gMail) { git config user.email "j.o.g.seinen@student.utwente.nl" }

    git add -A
    $pending = git status --porcelain
    if ($pending) {
        git commit -m "Course setup: R scripts and .gitignore" | Out-Null
        Write-Ok "eerste commit gemaakt"
    } else {
        Write-Ok "niets nieuws om te committen"
    }
} finally {
    Pop-Location
}

Write-Step "Klaar!"
Write-Host "    Open in VS Code: File > Open Folder > $CourseDir"
Write-Host "    Test in R:  source(""R/00_setup.R"")"
