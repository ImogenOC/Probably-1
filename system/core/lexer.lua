local find = string.find
local sub = string.sub

local actions = {
  { 'stopCasting', '^!' },
  { 'item', '^#' },
  { 'macro', '^/.*' },
  { 'spell', { '^[%w:!\',"%- ]*' } },
}

local rules = {
  { 'space', '^%s+' },
  { 'library', '^@' },
  { 'string', { '^\'.-\'', '^".-"' } },
  { 'logic', { '^and', '^or', '^&&', '^||' } },
  { 'not', { '^not%s', '^not$' } },
  { 'constant', { '^true', '^false', '^nil' } },
  { 'identifier', '^[_%a][_%w]*' },
  { 'comma', '^,' },
  { 'character', '^[:\']' },
  { 'number', { '^[%+%-]?%d+%.?%d*', '^%d+%.?%d*', '^%.%d+' } },
  { 'openParen', '^%(' },
  { 'closeParen', '^%)' },
  { 'openBracket', '^%[' },
  { 'closeBracket', '^%]' },
  { 'math', { '^%*', '^/', '^%-', '^%+', '^%%' } },
  { 'comparator', { '^>=', '^>', '^<=', '^<', '^==', '^=', '^!=', '~=' } },
  { 'not', '^!' },
  { 'period', '^%.' }
}

local tokenTables = {
  action = actions,
  rule = rules
}

local function parse(string, tokens, ignore)
  if not tokens then error('Missing the Token Table') end
  if type(tokens) == 'string' then
    if not tokenTables[tokens] then error('Unknown Token Table') end
    tokens = tokenTables[tokens]
  end

  if not ignore then ignore = { space = false } end

  local list = {}

  local index = 1
  local length = #string + 1

  while index < length do
    local found = false

    for i = 1, #tokens do
      local token, patterns = tokens[i][1], tokens[i][2]

      local loops = 1
      local patternType = type(patterns)
      if patternType == 'table' then loops = #patterns end

      for j = 1, loops do
        local pattern

        if patternType == 'table' then
          pattern = patterns[j]
        elseif patternType == 'string' then
          pattern = patterns
        end

        local sI, eI = find(string, pattern, index)
        if sI then
          local sub = sub(string, sI, eI)
          index = eI + 1
          found = true

          if ignore[token] then break end

          list[#list+1] = { token, sub }
          
          break
        end
      end
      
      if found then break end
    end

    if not found then return list, sub(string, index) end
  end

  return list
end

if require then
  return { parse = parse }
elseif ProbablyEngine then
  ProbablyEngine.lexer = { parse = parse }
end

