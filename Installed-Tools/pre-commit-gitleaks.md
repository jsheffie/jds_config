

Option 1: git-secrets (AWS-style pattern scanning)
Option 2: gitleaks (broader secret detection)
Option 3: pre-commit framework with detect-secrets

Went with option 2

already had pre-commit installed 
need to install gitleaks

```sh
brew install gitleaks
```

Run on all the files manually
```sh
gitleaks detect --source . -v
```