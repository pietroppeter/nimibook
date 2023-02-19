import std / strformat
import nimib, nimibook
import nimib / themes
from nimibook / commands import emptySrcFile
nbInit(theme = useNimibook)

nbText: """
# Content

The content of a chapter of a book can be a standard Markdown file (`.md`) or a `.nim` file.

The nim file must be a nimib document and the default content (created by `init` command) is:
"""
nbCode:
  discard
nb.blk.code = emptySrcFile("Default Content", ".nim")


nbText: """## Latex

Latex is available through [Katex](https://www.latex-project.org) as in Nimib.
It is enabled on a specific document with the command
"""
nbCode:
  nb.useLatex

nbText: &"""
which adds the following content in the head of the document:

```html
{themes.latex}
```
"""

let inline_paragraph = """
> Euler's identity is the equality
> $e^{i\pi} + 1 = 0$, where $e$ is the base of natural logarithms,
> $i$ is the imaginary unit, and $\pi$ is the ratio of circumference of a circle
> to its diameter.
"""
let block_equation = """
$$ 
  f(x) = \frac{1}{\sigma\sqrt{2\pi}} 
  \exp\left( -\frac{1}{2}\left(\frac{x-\mu}{\sigma}\right)^{\!2}\,\right)
$$
"""

nbText: &"""## Inline equations

**Inline equations** are obtained with delimiters `$..$`. The following inline paragraph:

{inline_paragraph}

...is created with the following source:

```md
{inline_paragraph}
```

## Block equations

**Block equations** are obtained with delimiters `$$ ... $$`. The follwing block equation:

{block_equation}

...is created with the following source:

```md
{block_equation}
```

### MathJax support

As in the original mdbook, you can opt instead to activate [MathJax support](https://rust-lang.github.io/mdBook/format/mathjax.html)
with:

```nim
nb.context["mathjax_support"] = true
```
"""

nbSave