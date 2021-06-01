import nimibook / types

proc setDefaults*(book: var Book) =
  book.language = "en-us"
  book.description = "a book built with nimibook"
  book.default_theme = "light"
  book.preferred_dark_theme = "navy"
  book.theme_option = {"light": "Light (default)", "rust": "Rust", "coal": "Coal", "navy": "Navy", "ayu": "Ayu"}.toTable
  book.favicon_escaped = """<link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2280%22>🐳</text></svg>">"""
  book.git_repository_icon = "fa-github"