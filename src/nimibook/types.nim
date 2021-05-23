type
  Entry* = object
    title*: string
    path*: string
    levels*: seq[int]
    isNumbered*: bool
  Toc* = object
    title*: string
    path*: string    
    entries*: seq[Entry]