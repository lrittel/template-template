# A template for templates

_It's templates all the way down._

My personal template to create templates with [Copier](https://copier.readthedocs.io/en/stable/).

The generated templates feature:

- the template itself in a subdirectory
- some basic testing
- a Nix devshell using flakes
- a direnv environment to automatically enter the Nix devshell
- a Nix app to use this template without cloning it or installing dependencies
- a readme

Usage:

```bash
# Without Nix
copier copy --trust "https://github.com/lrittel/template-template.git" <destination>

# With Nix
nix run "github:lrittel/template-template" -- copy --trust <destination>
```
