import std / [strutils, os, enumerate]
import nimib, nimib / paths
import nimibook / [types, books, entries, render]

proc useNimibook*(doc: var NbDoc) =
  doc.context["path_to_root"] = doc.homeDirRel.string & "/" # I probably should make sure to have / at the end
  doc.context["title"] = doc.thisFileRel.string

  # templates are in nbSrcDir
  doc.templateDirs = @[doc.srcDir.string]

  # Use nbSrcDir instead another relative path
  let bookPath = doc.srcDir.string / "book.json"
  # load book object
  var book = load(bookPath)

  # book configuration
  doc.context["language"] = book.language
  doc.context["default_theme"] = book.default_theme
  doc.context["description"] = book.description
  doc.context["favicon_escaped"] = book.favicon_escaped
  doc.context["preferred_dark_theme"] = book.preferred_dark_theme
  doc.context["theme_option"] = book.theme_option
  doc.context["book_title"] = book.book_title
  doc.context["git_repository_url"] = book.git_repository_url
  doc.context["git_repository_icon"] = book.git_repository_icon
  doc.context["plausible_analytics_url"] = book.plausible_analytics_url

  # process toc
  for i, entry in enumerate(book.toc.entries.mitems):
    if entry.url == doc.filename.replace('\\', '/'): # replace needed for windows
      entry.isActive = true
      if i > 0:
        doc.context["previous"] = book.toc.entries[i-1].url
      if i < book.toc.entries.high:
        doc.context["next"] = book.toc.entries[i+1].url
      break
  doc.partials["toc"] = render book.toc
