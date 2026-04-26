# Publishing `vworld.map` to GitHub

This package is ready to push. Below are the exact commands for two common
setups. Replace `soonmai` with a different GitHub username if you want.

---

## Option A — Using GitHub CLI (`gh`) — easiest

Prereqs: `git`, [`gh`](https://cli.github.com), and a one-time
`gh auth login`.

```bash
cd "/path/to/vworld.map"

# 1. initialize the local repo
git init -b main
git add .
git commit -m "Initial commit: vworld.map 0.1.0"

# 2. create the GitHub repo and push (public)
gh repo create soonmai/vworld.map \
    --public \
    --source=. \
    --remote=origin \
    --description "VWorld StaticMap API 2.0 client for R" \
    --push

# 3. tag the release
git tag -a v0.1.0 -m "vworld.map 0.1.0"
git push origin v0.1.0
```

After this, anyone can install with:

```r
remotes::install_github("soonmai/vworld.map")
```

---

## Option B — Using plain `git` only

```bash
cd "/path/to/vworld.map"

git init -b main
git add .
git commit -m "Initial commit: vworld.map 0.1.0"
```

Then go to <https://github.com/new>, create a repo named `vworld.map` (do **not**
initialize with README/LICENSE — we already have them), and run the commands
GitHub gives you, which look like:

```bash
git remote add origin https://github.com/soonmai/vworld.map.git
git branch -M main
git push -u origin main
git tag -a v0.1.0 -m "vworld.map 0.1.0"
git push origin v0.1.0
```

---

## Local sanity check before pushing (optional but recommended)

```bash
cd "/path/to"

# load + test in R
R -q -e 'devtools::load_all("vworld.map"); devtools::test("vworld.map")'

# full R CMD check
R CMD build vworld.map
R CMD check vworld.map_0.1.0.tar.gz --as-cran
```

If you have `devtools` you can also do:

```r
devtools::check("vworld.map")
```

---

## Adding a sample badge to README

After pushing, you can add an installation badge to `README.md`:

```markdown
[![R-CMD-check](https://github.com/soonmai/vworld.map/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/soonmai/vworld.map/actions/workflows/R-CMD-check.yaml)
```

(`usethis::use_github_action_check_standard()` will set up the workflow.)
