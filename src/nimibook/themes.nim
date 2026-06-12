import std / [strutils, os, enumerate, pathnorm, json, strformat, sequtils]
import nimib, nimib / themes
import nimibook / [types, commands, entries, toc_render]

const document* = hlHtml"""
<!DOCTYPE HTML>
<html lang="{{ language }}" class="sidebar-visible no-js {{ default_theme }}">
    <head>
        <!-- Book generated using nimibook -->
        <meta charset="UTF-8">
        <title>{{ title }}</title>
        {{#is_print }}
        <meta name="robots" content="noindex" />
        {{/is_print}}
        {{#base_url}}
        <base href="{{ base_url }}">
        {{/base_url}}

        <!-- Custom HTML head -->
        {{> head}}

        <meta content="text/html; charset=utf-8" http-equiv="Content-Type">
        <meta name="description" content="{{ description }}">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="theme-color" content="#ffffff" />

        {{&favicon_escaped}}
        {{#favicon_svg}}
        <link rel="icon" href="{{ path_to_root }}assets/favicon.svg">
        {{/favicon_svg}}
        {{#favicon_png}}
        <link rel="shortcut icon" href="{{ path_to_root }}assets/favicon.png">
        {{/favicon_png}}
        <link rel="stylesheet" href="{{ path_to_root }}assets/css/variables.css">
        <link rel="stylesheet" href="{{ path_to_root }}assets/css/general.css">
        <link rel="stylesheet" href="{{ path_to_root }}assets/css/chrome.css">
        {{#print_enable}}
        <link rel="stylesheet" href="{{ path_to_root }}assets/css/print.css" media="print">
        {{/print_enable}}

        <!-- Fonts -->
        <link rel="stylesheet" href="{{ path_to_root }}assets/FontAwesome/css/font-awesome.min.css">
        {{#copy_fonts}}
        <link rel="stylesheet" href="{{ path_to_root }}assets/fonts/fonts.css">
        {{/copy_fonts}}

        <!-- Highlight.js Stylesheets - I could use nimib native highlight but let's keep it for styling... -->
        <link rel="stylesheet" href="{{ path_to_root }}assets/css/highlight.css">
        <link rel="stylesheet" href="{{ path_to_root }}assets/css/tomorrow-night.css">
        <link rel="stylesheet" href="{{ path_to_root }}assets/css/ayu-highlight.css">

        <!-- Custom theme stylesheets - why the "../"? -->
        {{#additional_css}}
        <link rel="stylesheet" href="../{{ path_to_root }}{{ . }}">
        {{/additional_css}}

        {{#mathjax_support}}
        <!-- MathJax -->
        <script async type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
        {{/mathjax_support}}

        {{&latex}}

        {{^disableHighlightJs}}
            {{{highlightJs}}}
        {{/disableHighlightJs}}
        
        <!-- plausible analytics (new in nimibook) -->
        {{#plausible_analytics_url}}
        <script defer data-domain="{{plausible_analytics_url}}" src="https://plausible.io/js/plausible.js"></script>
        {{/plausible_analytics_url}}
    </head>
    <body>
        <!-- Provide site root to javascript -->
        <script type="text/javascript">
            var path_to_root = "{{ path_to_root }}/assets";
            var default_theme = window.matchMedia("(prefers-color-scheme: dark)").matches ? "{{ preferred_dark_theme }}" : "{{ default_theme }}";
        </script>

        <!-- Work around some values being stored in localStorage wrapped in quotes -->
        <script type="text/javascript">
            try {
                var theme = localStorage.getItem('mdbook-theme');
                var sidebar = localStorage.getItem('mdbook-sidebar');

                if (theme.startsWith('"') && theme.endsWith('"')) {
                    localStorage.setItem('mdbook-theme', theme.slice(1, theme.length - 1));
                }

                if (sidebar.startsWith('"') && sidebar.endsWith('"')) {
                    localStorage.setItem('mdbook-sidebar', sidebar.slice(1, sidebar.length - 1));
                }
            } catch (e) { }
        </script>

        <!-- Set the theme before any content is loaded, prevents flash -->
        <script type="text/javascript">
            var theme;
            try { theme = localStorage.getItem('mdbook-theme'); } catch(e) { }
            if (theme === null || theme === undefined) { theme = default_theme; }
            var html = document.querySelector('html');
            html.classList.remove('no-js')
            html.classList.remove('{{ default_theme }}')
            html.classList.add(theme);
            html.classList.add('js');
        </script>

        <!-- Hide / unhide sidebar before it is displayed -->
        <script type="text/javascript">
            var html = document.querySelector('html');
            var sidebar = 'hidden';
            if (document.body.clientWidth >= 1080) {
                try { sidebar = localStorage.getItem('mdbook-sidebar'); } catch(e) { }
                sidebar = sidebar || 'visible';
            }
            html.classList.remove('sidebar-visible');
            html.classList.add("sidebar-" + sidebar);
        </script>

        <nav id="sidebar" class="sidebar" aria-label="Table of contents">
            <div class="sidebar-scrollbox">
                {{> toc }}<!-- I could use also an unescaped context value -->
            </div>
            <div id="sidebar-resize-handle" class="sidebar-resize-handle"></div>
        </nav>

        <div id="page-wrapper" class="page-wrapper">

            <div class="page">
                {{> header}}
                <div id="menu-bar-hover-placeholder"></div>
                <div id="menu-bar" class="menu-bar sticky bordered">
                    <div class="left-buttons">
                        <button id="sidebar-toggle" class="icon-button" type="button" title="Toggle Table of Contents" aria-label="Toggle Table of Contents" aria-controls="sidebar">
                            <i class="fa fa-bars"></i>
                        </button>
                        <button id="theme-toggle" class="icon-button" type="button" title="Change theme" aria-label="Change theme" aria-haspopup="true" aria-expanded="false" aria-controls="theme-list">
                            <i class="fa fa-paint-brush"></i>
                        </button>
                        <ul id="theme-list" class="theme-popup" aria-label="Themes" role="menu">
                            <li role="none"><button role="menuitem" class="theme" id="light">{{#theme_option}}{{light}}{{/theme_option}}</button></li>
                            <li role="none"><button role="menuitem" class="theme" id="rust">{{#theme_option}}{{rust}}{{/theme_option}}</button></li>
                            <li role="none"><button role="menuitem" class="theme" id="coal">{{#theme_option}}{{coal}}{{/theme_option}}</button></li>
                            <li role="none"><button role="menuitem" class="theme" id="navy">{{#theme_option}}{{navy}}{{/theme_option}}</button></li>
                            <li role="none"><button role="menuitem" class="theme" id="ayu">{{#theme_option}}{{ayu}}{{/theme_option}}</button></li>
                        </ul>
                        {{#search_enabled}}
                        <button id="search-toggle" class="icon-button" type="button" title="Search. (Shortkey: s)" aria-label="Toggle Searchbar" aria-expanded="false" aria-keyshortcuts="S" aria-controls="searchbar">
                            <i class="fa fa-search"></i>
                        </button>
                        {{/search_enabled}}
                    </div>

                    <h1 class="menu-title">{{ book_title }}</h1>

                    <div class="right-buttons">
                        {{#print_enable}}
                        <a href="{{ path_to_root }}print.html" title="Print this book" aria-label="Print this book">
                            <i id="print-button" class="fa fa-print"></i>
                        </a>
                        {{/print_enable}}
                        {{#git_repository_url}}
                        <a href="{{git_repository_url}}" title="Git repository" aria-label="Git repository">
                            <i id="git-repository-button" class="fa {{git_repository_icon}}"></i>
                        </a>
                        {{/git_repository_url}}
                        {{#git_repository_edit_url}}
                        <a href="{{git_repository_edit_url}}" title="Suggest an edit" aria-label="Suggest an edit">
                            <i id="git-edit-button" class="fa fa-edit"></i>
                        </a>
                        {{/git_repository_edit_url}}

                    </div>
                </div>

                {{#search_enabled}}
                <div id="search-wrapper" class="hidden">
                    <form id="searchbar-outer" class="searchbar-outer">
                        <input type="search" id="searchbar" name="searchbar" placeholder="Search this book ..." aria-controls="searchresults-outer" aria-describedby="searchresults-header">
                    </form>
                    <div id="searchresults-outer" class="searchresults-outer hidden">
                        <div id="searchresults-header" class="searchresults-header"></div>
                        <ul id="searchresults">
                        </ul>
                    </div>
                </div>
                {{/search_enabled}}

                <!-- Apply ARIA attributes after the sidebar and the sidebar toggle button are added to the DOM -->
                <script type="text/javascript">
                    document.getElementById('sidebar-toggle').setAttribute('aria-expanded', sidebar === 'visible');
                    document.getElementById('sidebar').setAttribute('aria-hidden', sidebar !== 'visible');
                    Array.from(document.querySelectorAll('#sidebar a')).forEach(function(link) {
                        link.setAttribute('tabIndex', sidebar === 'visible' ? 0 : -1);
                    });
                </script>

                <div id="content" class="content">
                    <main>
                        {{#blocks}}
                        {{&.}}
                        {{/blocks}}
                    </main>

                    <nav class="nav-wrapper" aria-label="Page navigation">
                        <!-- Mobile navigation buttons -->
                        {{#previous}}
                            <a rel="prev" href="{{ path_to_root }}{{previous}}" class="mobile-nav-chapters previous" title="Previous chapter" aria-label="Previous chapter" aria-keyshortcuts="Left">
                                <i class="fa fa-angle-left"></i>
                            </a>
                        {{/previous}}

                        {{#next}}
                            <a rel="next" href="{{ path_to_root }}{{next}}" class="mobile-nav-chapters next" title="Next chapter" aria-label="Next chapter" aria-keyshortcuts="Right">
                                <i class="fa fa-angle-right"></i>
                            </a>
                        {{/next}}

                        <div style="clear: both"></div>
                    </nav>
                </div>
            </div>

            <nav class="nav-wide-wrapper" aria-label="Page navigation">
                {{#previous}}
                    <a rel="prev" href="{{ path_to_root }}{{previous}}" class="nav-chapters previous" title="Previous chapter" aria-label="Previous chapter" aria-keyshortcuts="Left">
                        <i class="fa fa-angle-left"></i>
                    </a>
                {{/previous}}

                {{#next}}
                    <a rel="next" href="{{ path_to_root }}{{next}}" class="nav-chapters next" title="Next chapter" aria-label="Next chapter" aria-keyshortcuts="Right">
                        <i class="fa fa-angle-right"></i>
                    </a>
                {{/next}}
            </nav>

        </div>

        {{#livereload}}
        <!-- Livereload script (if served using the cli tool) -->
        <script type="text/javascript">
            var socket = new WebSocket("{{{livereload}}}");
            socket.onmessage = function (event) {
                if (event.data === "reload") {
                    socket.close();
                    location.reload();
                }
            };

            window.onbeforeunload = function() {
                socket.close();
            }
        </script>
        {{/livereload}}

        {{#google_analytics}}
        <!-- Google Analytics Tag -->
        <script type="text/javascript">
            var localAddrs = ["localhost", "127.0.0.1", ""];

            // make sure we don't activate google analytics if the developer is
            // inspecting the book locally...
            if (localAddrs.indexOf(document.location.hostname) === -1) {
                (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
                })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

                ga('create', '{{google_analytics}}', 'auto');
                ga('send', 'pageview');
            }
        </script>
        {{/google_analytics}}

        {{#playground_line_numbers}}
        <script type="text/javascript">
            window.playground_line_numbers = true;
        </script>
        {{/playground_line_numbers}}

        {{#playground_copyable}}
        <script type="text/javascript">
            window.playground_copyable = true;
        </script>
        {{/playground_copyable}}

        {{#playground_js}}
        <script src="{{ path_to_root }}ace.js" type="text/javascript" charset="utf-8"></script>
        <script src="{{ path_to_root }}editor.js" type="text/javascript" charset="utf-8"></script>
        <script src="{{ path_to_root }}mode-rust.js" type="text/javascript" charset="utf-8"></script>
        <script src="{{ path_to_root }}theme-dawn.js" type="text/javascript" charset="utf-8"></script>
        <script src="{{ path_to_root }}theme-tomorrow_night.js" type="text/javascript" charset="utf-8"></script>
        {{/playground_js}}

        {{#search_js}}
        <script src="{{ path_to_root }}elasticlunr.min.js" type="text/javascript" charset="utf-8"></script>
        <script src="{{ path_to_root }}mark.min.js" type="text/javascript" charset="utf-8"></script>
        <script src="{{ path_to_root }}searcher.js" type="text/javascript" charset="utf-8"></script>
        {{/search_js}}

        <script src="{{ path_to_root }}assets/js/clipboard.min.js" type="text/javascript" charset="utf-8"></script>
        <script src="{{ path_to_root }}assets/js/book.js" type="text/javascript" charset="utf-8"></script>

        <!-- Custom JS scripts -->
        {{#additional_js}}
        <script type="text/javascript" src="{{ ../path_to_root }}{{ . }}"></script>
        {{/additional_js}}

        {{#is_print}}
        {{#mathjax_support}}
        <script type="text/javascript">
        window.addEventListener('load', function() {
            MathJax.Hub.Register.StartupHook('End', function() {
                window.setTimeout(window.print, 100);
            });
        });
        </script>
        {{/mathjax_support}}
        {{^mathjax_support}}
        <script type="text/javascript">
        window.addEventListener('load', function() {
            window.setTimeout(window.print, 100);
        });
        </script>
        {{/mathjax_support}}
        {{/is_print}}

    </body>
</html>
"""

func nimibookHeadToHtml*(blk: JsonNode, nb: Nb): string =
  let path_to_root = nb.doc.context{"path_to_root"}.getStr
  let title = nb.doc.context{"title"}.getStr
  let description = nb.doc.context{"description"}.getStr
  let isPrint = nb.doc.context{"is_print"}.getBool
  let baseUrl = nb.doc.context{"base_url"}.getStr
  let faviconEscaped = nb.doc.context{"favicon_escaped"}.getStr
  let faviconSvg = nb.doc.context{"favicon_svg"}.getStr
  let faviconPng = nb.doc.context{"favicon_png"}.getStr
  let printEnable = nb.doc.context{"favicon_png"}.getBool
  let copyFonts = nb.doc.context{"copy_fonts"}.getBool
  let additionalCSS = nb.doc.context{"additional_css"}.getElems.map(proc(j: JsonNode): string = j.getStr)
  let mathJaxSupport = nb.doc.context{"mathjax_support"}.getBool
  let latex = nb.doc.context{"latex"}.getStr
  let highlightJs = nb.doc.context{"highlightJs"}.getStr
  let disableHighlightJs = nb.doc.context{"disableHighlightJs"}.getBool
  let plausibleAnalyticsUrl = nb.doc.context{"plausible_analytics_url"}.getStr
  # TODO: move all static html content into a single html string
  result = withNewlines:
    hlHtmlF"""
    <head>
      <!-- Book generated using nimibook -->
      <meta charset="UTF-8">
      <title>{ title }</title>"""
    if isPrint:
      """<meta name="robots" content="noindex" />"""
    if baseUrl.len > 0:
      hlHtmlF"""<base href="{ baseUrl }">"""
    nb.renderPartial("head", blk)
    hlHtmlF"""
      <meta content="text/html; charset=utf-8" http-equiv="Content-Type">
      <meta name="description" content="{description}">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <meta name="theme-color" content="#ffffff" />
      {faviconEscaped}
    """
    if faviconSvg.len > 0:
      hlHtmlF"""<link rel="icon" href="{path_to_root}assets/favicon.svg">"""
    if faviconPng.len > 0:
      hlHtmlF"""<link rel="shortcut icon" href="{path_to_root}assets/favicon.png">"""
    hlHtmlF"""
      <link rel="stylesheet" href="{path_to_root}assets/css/variables.css">
      <link rel="stylesheet" href="{path_to_root}assets/css/general.css">
      <link rel="stylesheet" href="{path_to_root}assets/css/chrome.css">
    """
    if printEnable:
      hlHtmlF"""<link rel="stylesheet" href="{path_to_root}assets/css/print.css" media="print">"""
    hlHtmlF"""
      <link rel="stylesheet" href="{path_to_root}assets/FontAwesome/css/font-awesome.min.css">
    """
    if copyFonts:
      hlHtmlF"""<link rel="stylesheet" href="{path_to_root}assets/fonts/fonts.css">"""
    hlHtmlF"""
      <link rel="stylesheet" href="{path_to_root}assets/css/highlight.css">
      <link rel="stylesheet" href="{path_to_root}assets/css/tomorrow-night.css">
      <link rel="stylesheet" href="{path_to_root}assets/css/ayu-highlight.css">
    """
    for stylesheet in additionalCSS:
      hlHtmlF"""<link rel="stylesheet" href="../{path_to_root}{stylesheet}">"""
    if mathJaxSupport:
      hlHtml"""<script async type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>"""
    latex
    if not disableHighlightJs:
      highlightJs
    if plausibleAnalyticsUrl.len > 0:
      hlHtmlF"""<script defer data-domain="{plausibleAnalyticsUrl}" src="https://plausible.io/js/plausible.js"></script>"""
    "</head>"

func nimibookBodyPreToHtml*(blk: JsonNode, nb: Nb): string =
  withNewLines:
    hlHtml"""
<!-- Provide site root to javascript -->
<script type="text/javascript">
    var path_to_root = "{{ path_to_root }}/assets";
    var default_theme = window.matchMedia("(prefers-color-scheme: dark)").matches ? "{{ preferred_dark_theme }}" : "{{ default_theme }}";
</script>

<!-- Work around some values being stored in localStorage wrapped in quotes -->
<script type="text/javascript">
    try {
        var theme = localStorage.getItem('mdbook-theme');
        var sidebar = localStorage.getItem('mdbook-sidebar');

        if (theme.startsWith('"') && theme.endsWith('"')) {
            localStorage.setItem('mdbook-theme', theme.slice(1, theme.length - 1));
        }

        if (sidebar.startsWith('"') && sidebar.endsWith('"')) {
            localStorage.setItem('mdbook-sidebar', sidebar.slice(1, sidebar.length - 1));
        }
    } catch (e) { }
</script>

<!-- Set the theme before any content is loaded, prevents flash -->
<script type="text/javascript">
    var theme;
    try { theme = localStorage.getItem('mdbook-theme'); } catch(e) { }
    if (theme === null || theme === undefined) { theme = default_theme; }
    var html = document.querySelector('html');
    html.classList.remove('no-js')
    html.classList.remove('{{ default_theme }}')
    html.classList.add(theme);
    html.classList.add('js');
</script>

<!-- Hide / unhide sidebar before it is displayed -->
<script type="text/javascript">
    var html = document.querySelector('html');
    var sidebar = 'hidden';
    if (document.body.clientWidth >= 1080) {
        try { sidebar = localStorage.getItem('mdbook-sidebar'); } catch(e) { }
        sidebar = sidebar || 'visible';
    }
    html.classList.remove('sidebar-visible');
    html.classList.add("sidebar-" + sidebar);
</script>
    """

func nimibookBodyNavToHtml*(blk: JsonNode, nb: Nb): string =
  withNewLines:
    hlHtml"""
<nav id="sidebar" class="sidebar" aria-label="Table of contents">
    <div class="sidebar-scrollbox">
        {{> toc }}<!-- I could use also an unescaped context value -->
    </div>
    <div id="sidebar-resize-handle" class="sidebar-resize-handle"></div>
</nav>    
"""

func nimibookBodyPageWrapperToHtml*(blk: JsonNode, nb: Nb): string =
  withNewLines:
    hlHtml"""
<div id="page-wrapper" class="page-wrapper">

  <div class="page">
      {{> header}}
      <div id="menu-bar-hover-placeholder"></div>
      <div id="menu-bar" class="menu-bar sticky bordered">
          <div class="left-buttons">
              <button id="sidebar-toggle" class="icon-button" type="button" title="Toggle Table of Contents" aria-label="Toggle Table of Contents" aria-controls="sidebar">
                  <i class="fa fa-bars"></i>
              </button>
              <button id="theme-toggle" class="icon-button" type="button" title="Change theme" aria-label="Change theme" aria-haspopup="true" aria-expanded="false" aria-controls="theme-list">
                  <i class="fa fa-paint-brush"></i>
              </button>
              <ul id="theme-list" class="theme-popup" aria-label="Themes" role="menu">
                  <li role="none"><button role="menuitem" class="theme" id="light">{{#theme_option}}{{light}}{{/theme_option}}</button></li>
                  <li role="none"><button role="menuitem" class="theme" id="rust">{{#theme_option}}{{rust}}{{/theme_option}}</button></li>
                  <li role="none"><button role="menuitem" class="theme" id="coal">{{#theme_option}}{{coal}}{{/theme_option}}</button></li>
                  <li role="none"><button role="menuitem" class="theme" id="navy">{{#theme_option}}{{navy}}{{/theme_option}}</button></li>
                  <li role="none"><button role="menuitem" class="theme" id="ayu">{{#theme_option}}{{ayu}}{{/theme_option}}</button></li>
              </ul>
              {{#search_enabled}}
              <button id="search-toggle" class="icon-button" type="button" title="Search. (Shortkey: s)" aria-label="Toggle Searchbar" aria-expanded="false" aria-keyshortcuts="S" aria-controls="searchbar">
                  <i class="fa fa-search"></i>
              </button>
              {{/search_enabled}}
          </div>

          <h1 class="menu-title">{{ book_title }}</h1>

          <div class="right-buttons">
              {{#print_enable}}
              <a href="{{ path_to_root }}print.html" title="Print this book" aria-label="Print this book">
                  <i id="print-button" class="fa fa-print"></i>
              </a>
              {{/print_enable}}
              {{#git_repository_url}}
              <a href="{{git_repository_url}}" title="Git repository" aria-label="Git repository">
                  <i id="git-repository-button" class="fa {{git_repository_icon}}"></i>
              </a>
              {{/git_repository_url}}
              {{#git_repository_edit_url}}
              <a href="{{git_repository_edit_url}}" title="Suggest an edit" aria-label="Suggest an edit">
                  <i id="git-edit-button" class="fa fa-edit"></i>
              </a>
              {{/git_repository_edit_url}}

          </div>
      </div>

      {{#search_enabled}}
      <div id="search-wrapper" class="hidden">
          <form id="searchbar-outer" class="searchbar-outer">
              <input type="search" id="searchbar" name="searchbar" placeholder="Search this book ..." aria-controls="searchresults-outer" aria-describedby="searchresults-header">
          </form>
          <div id="searchresults-outer" class="searchresults-outer hidden">
              <div id="searchresults-header" class="searchresults-header"></div>
              <ul id="searchresults">
              </ul>
          </div>
      </div>
      {{/search_enabled}}

      <!-- Apply ARIA attributes after the sidebar and the sidebar toggle button are added to the DOM -->
      <script type="text/javascript">
          document.getElementById('sidebar-toggle').setAttribute('aria-expanded', sidebar === 'visible');
          document.getElementById('sidebar').setAttribute('aria-hidden', sidebar !== 'visible');
          Array.from(document.querySelectorAll('#sidebar a')).forEach(function(link) {
              link.setAttribute('tabIndex', sidebar === 'visible' ? 0 : -1);
          });
      </script>

      <div id="content" class="content">
          <main>
              {{#blocks}}
              {{&.}}
              {{/blocks}}
          </main>

          <nav class="nav-wrapper" aria-label="Page navigation">
              <!-- Mobile navigation buttons -->
              {{#previous}}
                  <a rel="prev" href="{{ path_to_root }}{{previous}}" class="mobile-nav-chapters previous" title="Previous chapter" aria-label="Previous chapter" aria-keyshortcuts="Left">
                      <i class="fa fa-angle-left"></i>
                  </a>
              {{/previous}}

              {{#next}}
                  <a rel="next" href="{{ path_to_root }}{{next}}" class="mobile-nav-chapters next" title="Next chapter" aria-label="Next chapter" aria-keyshortcuts="Right">
                      <i class="fa fa-angle-right"></i>
                  </a>
              {{/next}}

              <div style="clear: both"></div>
          </nav>
      </div>
  </div>

  <nav class="nav-wide-wrapper" aria-label="Page navigation">
      {{#previous}}
          <a rel="prev" href="{{ path_to_root }}{{previous}}" class="nav-chapters previous" title="Previous chapter" aria-label="Previous chapter" aria-keyshortcuts="Left">
              <i class="fa fa-angle-left"></i>
          </a>
      {{/previous}}

      {{#next}}
          <a rel="next" href="{{ path_to_root }}{{next}}" class="nav-chapters next" title="Next chapter" aria-label="Next chapter" aria-keyshortcuts="Right">
              <i class="fa fa-angle-right"></i>
          </a>
      {{/next}}
  </nav>

</div>
"""

func nimibookBodyPostToHtml*(blk: JsonNode, nb: Nb): string =
  let path_to_root = nb.doc.context{"path_to_root"}.getStr
  let search_js = nb.doc.context{"search_js"}.getBool
  let additional_js = nb.doc.context{"additional_js"}.getElems.map(proc(j: JsonNode): string = j.getStr)
  let is_print = nb.doc.context{"is_print"}.getBool
  let mathjax_support = nb.doc.context{"mathjax_support"}.getBool
  withNewLines:
    if search_js:
      hlHtmlF"""
<script src="{path_to_root}elasticlunr.min.js" type="text/javascript" charset="utf-8"></script>
<script src="{path_to_root}mark.min.js" type="text/javascript" charset="utf-8"></script>
<script src="{path_to_root}searcher.js" type="text/javascript" charset="utf-8"></script>    
"""
    hlHtmlF"""
<script src="{path_to_root}assets/js/clipboard.min.js" type="text/javascript" charset="utf-8"></script>
<script src="{path_to_root}assets/js/book.js" type="text/javascript" charset="utf-8"></script>
"""
    for jsFile in additional_js:
      hlHtmlF"""<script type="text/javascript" src="{path_to_root}{jsFile}"></script>"""
    if is_print:
      if mathjax_support:
        hlHtml"""
          <script type="text/javascript">
window.addEventListener('load', function() {
    MathJax.Hub.Register.StartupHook('End', function() {
        window.setTimeout(window.print, 100);
    });
});
</script>
"""
      else:
        hlHtml"""
<script type="text/javascript">
window.addEventListener('load', function() {
    window.setTimeout(window.print, 100);
});
</script>
"""


func nimibookBodyToHtml*(blk: JsonNode, nb: Nb): string =
  result = withNewlines:
    "<body>"
    nb.renderPartial("nimibook_body_pre", blk)
    nb.renderPartial("nimibook_body_nav", blk)
    nb.renderPartial("nimibook_body_page_wrapper", blk)
    nb.renderPartial("nimibook_body_post", blk)
    "</body>"

func nimibookNbDocToHtml*(blk: NbBlock, nb: Nb): string =
  let doc = blk.NbDoc
  let lang = nb.doc.context{"language"}.getStr
  let defaultTheme = nb.doc.context{"default_theme"}.getStr
  # it's unused
  let docJson = %[]

  let renderedBlocks = nbContainerToHtml(doc, nb)
  doc.context["renderedBlocks"] = %renderedBlocks

  result = withNewLines:
    "<!DOCTYPE HTML>"
    &"""<html lang="{ lang }" class="sidebar-visible no-js { defaultTheme }">"""
    nb.renderPartial("nimibook_head", docJson)
    nb.renderPartial("nimibook_body", docJson)
    "</html>"

proc useNimibook*(nb: var Nb) =
  nb.doc.context["path_to_root"] = %(nb.doc.srcDirRel.string & "/") # I probably should make sure to have / at the end

  nb.backend.funcs["NbDoc"] = nimibookNbDocToHtml
  nb.backend.partials["nimibook_head"] = nimibookHeadToHtml
  nb.backend.partials["nimibook_body"] = nimibookBodyToHtml
  nb.backend.partials["nimibook_body_pre"] = nimibookBodyPreToHtml
  nb.backend.partials["nimibook_body_nav"] = nimibookBodyNavToHtml
  nb.backend.partials["nimibook_body_page_wrapper"] = nimibookBodyPageWrapperToHtml
  nb.backend.partials["nimibook_body_post"] = nimibookBodyPostToHtml

  # book.json is publicly accessible (sort of a public static api)
  let bookPath = nb.doc.homeDir.string / "book.json"
  # load book object
  var book = load(bookPath)

  # book configuration
  nb.doc.context["language"] = %book.language
  nb.doc.context["default_theme"] = %book.default_theme
  nb.doc.context["description"] = %book.description
  nb.doc.context["favicon_escaped"] = %book.favicon_escaped
  nb.doc.context["preferred_dark_theme"] = %book.preferred_dark_theme
  nb.doc.context["theme_option"] = %book.theme_option
  nb.doc.context["book_title"] = %book.title
  nb.doc.context["git_repository_url"] = %book.git_repository_url
  nb.doc.context["git_repository_icon"] = %book.git_repository_icon
  nb.doc.context["plausible_analytics_url"] = %book.plausible_analytics_url
  nb.doc.context["highlightJs"] = %highlightJsTags

  var thisEntry: Entry
  # process toc
  for i, entry in enumerate(book.toc.entries.mitems):
    if normalizePath(entry.url) == normalizePath(nb.doc.filename.replace('\\', '/')): # replace needed for windows
      thisEntry = entry
      entry.isActive = true
      let
        prevUrl = book.prevEntryUrl i
        nextUrl = book.nextEntryUrl i
      if prevUrl.len > 0:
        nb.doc.context["previous"] = %prevUrl
      if nextUrl.len > 0:
        nb.doc.context["next"] = %nextUrl
      break
  nb.doc.context["toc"] = %(render book.toc)

  # html.head.title (what appears in the tab)
  nb.doc.context["title"] = %(thisEntry.title & " - " & book.title)
