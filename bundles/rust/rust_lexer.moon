-- Copyright 2016 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)


howl.util.lpeg_lexer ->
  c = capture
  -- shorthand for lexer.word
  ident = (alpha + '_')^1 * (alpha + digit + '_')^0


  -- Comments.
  line_comment = P'//' * scan_until eol
  block_comment = span '/*', '*/'
  comment = c 'comment', any {line_comment, block_comment}


  -- Strings.
  dq_str = span  '"', '"', '\\'
  raw_str_start = P'r'^0 * Cg(P'#'^0, 'lvl') * '"'
  raw_str_end = '"' * match_back 'lvl'
  raw_str = raw_str_start * scan_to raw_str_end
  -- Character.
  anychar = alpha + digit + '_' + space
  char = P"'" * (('\\' * anychar) + anychar) * P"'"
  string  = c 'string', any {dq_str, raw_str, char}


  -- Numbers.
  binary = P'0b'^-1 * S'01_'^1
  number = c 'number', any {
    binary,
    hexadecimal,
    octal,
    (digit + '_')^1 -- decimal integer
    float
  }


  -- Keywords.
  keyword = c 'keyword', word {
    'abstract',   'alignof',    'as',       'become',   'box',
    'break',      'const',      'continue', 'crate',    'do',
    'else',       'enum',       'extern',   'false',    'final',
    'fn',         'for',        'if',       'impl',     'in',
    'let',        'loop',       'macro',    'match',    'mod',
    'move',       'mut',        "offsetof", 'override', 'priv',
    'proc',       'pub',        'pure',     'ref',      'return',
    'Self',       'self',       'sizeof',   'static',   'struct',
    'super',      'trait',      'true',     'type',     'typeof',
    'unsafe',     'unsized',    'use',      'virtual',  'where',
    'while',      'yield'
  }


   -- Primitive Types.
  primitive = word {
    'bool', 'isize', 'usize', 'char', 'str',
    'u8', 'u16', 'u32', 'u64', 'i8', 'i16', 'i32', 'i64',
    'f32','f64',
  }
  -- Library Types.
  library = upper^1 * (lower + digit)^1
  -- Lifetimes.
  lifetime = "'" * ident
  type = c 'type', any {lifetime, primitive}
  type_library = c 'constant', library


  -- Identifiers.
  identifier = c 'identifier', ident


  -- Operators.
  operator = c 'operator', S'+-/*%<>!=`^~@&|?#~:;,.()[]{}'


  -- Attributes.
  attribute = c 'preproc', (span (P'#![' + P'#['), P']')


  -- Syntax extensions.
  extension = c 'special', any {ident * S'!'}


  P {
    'all'

    all: any {
      keyword,
      extension,
      type_library,
      type,
      comment,
      string,
      attribute,
      number,
      operator,
      identifier,
    }
  }

