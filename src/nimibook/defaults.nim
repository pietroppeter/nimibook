import nimibook / types

proc setDefaults*(book: var Book) =
  template setIfEmpty(field, value: untyped) =
    if len(book.`field`) == 0:
      book.`field` = value
  setIfEmpty language, "en-us"
  setIfEmpty title, "My book"
  setIfEmpty description, "a book built with nimibook"
  setIfEmpty default_theme, "light"
  setIfEmpty preferred_dark_theme, "navy"
  setIfEmpty theme_option, {"light": "Light (default)", "rust": "Rust", "coal": "Coal", "navy": "Navy", "ayu": "Ayu"}.toTable
  setIfEmpty favicon_escaped, """<link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2280%22>🐳</text></svg>">"""
  setIfEmpty git_repository_icon, "fa-github"
