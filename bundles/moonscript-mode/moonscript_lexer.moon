howl.aux.lpeg_lexer ->

  keyword = capture 'keyword', word {
    'return', 'break', 'local', 'for', 'while', 'if', 'else', 'elseif', 'then',
    'export', 'import', 'from', 'with', 'in', 'and', 'or', 'not', 'class',
    'extends', 'super', 'do', 'using', 'switch', 'when', 'unless'
  }

  comment = capture 'comment', span('--', eol)

  hexadecimal_number =  P'0' * S'xX' * xdigit^1 * (P'.' * xdigit^1)^0 * (S'pP' * S'-+'^0 * xdigit^1)^0
  float = digit^0 * P'.' * digit^1
  number = capture 'number', any({
    hexadecimal_number,
    (float + digit^1) * (S'eE' * P('-')^0 * digit^1)^0
  })

  operator = capture 'operator', any {
    S'+-*!\\/%^#=<>;:,.(){}[]',
    any { '~=', 'or=', 'and=' }
  }

  ident = (alpha + '_')^1 * (alpha + digit + '_')^0

  identifier = capture 'identifier', ident
  member = capture 'member', (P'@' + 'self.') * ident^0
  special = capture 'special', any { 'true', 'false', 'nil' }
  clazz = capture 'class', upper^1 * (alpha + digit + '_')^0

  lua_keywords = capture 'error', word { 'function', 'goto', 'end' }

  sq_string = span("'", "'", '\\')
  dq_string = span('"', '"', P'\\')
  long_string = span('[[', ']]', '\\')

  key = capture 'key', any {
    P':' * ident,
    ident * P':',
    (sq_string + dq_string) * P':'
  }

  dq_string_end = scan_to(P'"' + #P'#{', P'\\')

  P {
    'all'
    all: any { number, key, V'string', comment, operator, special, keyword, member, clazz, lua_keywords, identifier }
    string: any {
      capture 'string', any { sq_string, long_string }
      V'dq_string'
    }
    interpolation: #P'#' * (-P'}' * (V'all' + 1))^1 * capture('operator', '}') * V'dq_string_chunk'
    dq_string_chunk: capture('string', scan_to(P'"' + #P'#{', P'\\')) * V('interpolation')^0
    dq_string: capture('string', '"') * (V'dq_string_chunk')
  }
