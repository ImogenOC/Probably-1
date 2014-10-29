local lexer
if require then
  lexer = require('lexer')
elseif ProbablyEngine then
  lexer = ProbablyEngine.lexer
end

local _G = _G
local format = string.format
local smt = setmetatable
local sub = string.sub

-- Identifiers
local identifiers = {}

local function register(identifier, tbl)
  if identifiers[identifier] then error('Identifier already exists: ' .. identifier) end

  identifiers[identifier] = tbl
end

local function unregister(identifier)
  if not identifiers[identifier] then error('Invalid Identifier') end

  identifiers[identifier] = nil
end

-- Symbols
local NewSymbol = {}
function NewSymbol.__call(t, k)
  return smt(k or {}, t)
end

local function Symbol(prototype)
  if not prototype.lbp then
    prototype.lbp = 0
  end
  prototype.__index = prototype
  function prototype.__tostring(self)
    if self.id == ',' then return '(,)' end

    if self.id == 'Number' or self.id == 'Constant' or self.id == 'Identifier' or self.id == 'Character' or self.id == 'String' then
      return format('(%s %s)', self.id, tostring(self.value) or 'None')
    end

    if self.id == 'Args' then
      local arguments = ''
      for i = 1, #self.value do
        local argument = ''
        for j = 1, #self.value[i] do
          argument = argument .. tostring(self.value[i][j])
        end
        arguments = arguments .. format(' %s', argument)
      end
      if #self.value == 0 then arguments = ' None' end
      return format('(%s%s)', self.id, arguments)
    end

    return format('(%s %s %s)', self.id, tostring(self.first) or 'None', tostring(self.second) or 'None')
  end
  function prototype:led(left, expression)
    self.first = left
    self.second = expression(self.lbp)
    return self
  end
  function prototype:eval(action)
    local first = self.first and self.first:evaluate(action)
    local second = self.second and self.second:evaluate(action)

    if type(first) == 'function' then first = first(self.first.self) end
    if type(second) == 'function' then second = second(self.second.self) end

    if type(first) == 'table' and first.__call then first = first.__call(first) end
    if type(second) == 'table' and second.__call then second = second.__call(second) end

    if type(first) == 'table' and first.condition then
      if ProbablyEngine.condition[first.condition] == nil then
        print('#ERROR condition not found', first.condition)
        return
      end

      if first.arguments then
        print('>> ', first.condition, first.target, unpack(first.arguments))
        first = ProbablyEngine.condition[first.condition](first.target, unpack(first.arguments))
      else
        print('>> ', first.condition, first.target, action)
        first = ProbablyEngine.condition[first.condition](first.target, action)
      end
    end

    return first, second
  end
  return smt(prototype, NewSymbol)
end

local Number = Symbol({ id = 'Number' })
function Number:nud(expression)
  return self
end
function Number:evaluate()
  return self.value
end

local Constant = Symbol({ id = 'Constant' })
function Constant:nud(expression)
  return self
end
function Constant:evaluate()
  if self.value == 'true' then return true
  elseif self.value == 'false' then return false
  elseif self.value == 'nil' then return nil end
end

local Identifier = Symbol({ id = 'Identifier' })
function Identifier:nud(expression)
  return self
end
function Identifier:evaluate()
  if self.class then return self.value end

  if self.root then
    self.class = 'root'
  elseif ProbablyEngine.condition[self.value] ~= nil
         or self.value == "area" or self.value == "balance"
         or self.value == "buff" or self.value == "buffs"
         or self.value == "casting" or self.value == "debuff"
         or self.value == "enchant" or self.value == "health"
         or self.value == "raid" or self.value == "runes"
         or self.value == "spell" or self.value == "totem" then
    self.class = 'condition'
  else
    self.class = 'string'
  end

  return self.value
end

local Library = Symbol({ id = '@' })
function Library:nud(expression)
  return self
end
function Library:evaluate()
  print('TODO: Library')
end

local function checkLeft(left)
  if left.first then
    return checkLeft(left.first)
  end

  if left.id ~= 'Identifier' then
    error('Expected an Identifier: ' .. left.value)
  end
end

local Period = Symbol({ id = '.', lbp = 150 })
function Period:nud() error('Period expects an Identifier') end
function Period:led(left, expression, verify, token)
  -- Validation
  checkLeft(left)

  if token.id ~= 'Identifier' then
    error('Expected  an Identifier: ' .. token.value)
  end

  if left.id == 'Identifier' then
    left.root = true
  end

  self.first = left
  self.second = token
  verify()

  return self
end
function Period:evaluate(action)
  if self.cache then return self.cache end

  local first = self.first and self.first:evaluate(action)
  local second = self.second and self.second:evaluate(action)

  if self.first.class == 'root' and self.second.class == 'condition' then
    if self.first.value == 'modifier' then
      self.cache = { target = nil, condition = self.first.value .. '.' .. second }
    else
      self.cache = { target = self.first.value, condition = second }
    end

    return self.cache
  end

  if type(first) == 'table' and first.condition then
    first.condition = first.condition .. '.' .. second
    self.cache = first
    return self.cache
  end

  if first == nil then
    print('Period Tried to call but was nil: ' .. tostring(self.first))
    return false
  end

  if not first then
    return false
  end

  if first[second] then
    self.self = first
    return first[second]
  end

  return nil
end

local Comma = Symbol({ id = ',' })
function Comma:nud()
  return self
end
function Comma:evaluate()
  error('TYPO COMMA EVAL')
end

local String = Symbol({ id = 'String' })
function String:nud() return self end
function String:evaluate() return self.value end
local Dash = Symbol({ id = 'Dash' })
function Dash:nud() return self end
local Space = Symbol({ id = 'Space' })
function Space:nud() return self end
local Character = Symbol({ id = 'Character' })
function Character:nud() return self end

local Args = Symbol({ id = 'Args' })
function Args:led(left, expression)
  self.first = left
  self.second = expression(self.lbp - 1)
  return self
end

local Add = Symbol({ id = '+', lbp = 110 })
function Add:nud(expression)
  self.first = expression(130)
  self.second = Number({ value = 0 })
  return self
end
function Add:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first + second
end

local Subtract = Symbol({ id = '-', lbp = 110 })
function Subtract:nud(expression)
  self.first = Number({ value = 0 })
  self.second = expression(130)
  return self
end
function Subtract:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first - second
end

local Multiply = Symbol({ id = '*', lbp = 120 })
function Multiply:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first * second
end

local Divide = Symbol({ id = '/', lbp = 120 })
function Divide:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end
  
  return first / second
end

local Modulus = Symbol({ id = '%', lbp = 120 })
function Modulus:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first % second
end

local LesserThan = Symbol({ id = '<', lbp = 60 })
function LesserThan:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first < second
end

local LesserThanEqual = Symbol({ id = '<=', lbp = 60 })
function LesserThanEqual:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first <= second
end

local GreaterThan = Symbol({ id = '>', lbp = 60 })
function GreaterThan:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first > second
end

local GreaterThanEqual = Symbol({ id = '>=', lbp = 60 })
function GreaterThanEqual:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first >= second
end

local Equal = Symbol({ id = '==', lbp = 60 })
function Equal:evaluate(action)
  local first, second = self:eval(action)

  return first == second
end

local NotEqual = Symbol({ id = '~=', lbp = 60 })
function NotEqual:evaluate(action)
  local first, second = self:eval(action)

  return first ~= second
end

function checkArgument(argument)
  if #argument > 0 and argument[1].id == 'Identifier' then
    if #argument > 1 then
      for i = 2, #argument do
        argument[1].value = argument[1].value .. argument[i].value
      end
    end
    argument = { String({ value = argument[1].value }) }
  end

  return argument
end

local LeftParathesis = Symbol({ id = '(', lbp = 150 })
function LeftParathesis:led(left, expression, verify, token)
  self.first = left
  self.second = {}
  if token.id ~= ')' then
    local arg = {}
    while true do
      local expr, nextToken = expression(0, true)
      arg[#arg + 1] = expr

      if nextToken.id == ',' then
        verify(',')
        self.second[#self.second + 1] = checkArgument(arg)
        arg = {}
      end

      if nextToken.id == ')' then
        self.second[#self.second + 1] = checkArgument(arg)
        arg = {}
        break
      end

      if nextToken.id == 'Null' then error('#TYPO NULL') end
    end
  end
  verify(')')
  self.second = Args({ value = self.second }) 
  return self
end
function LeftParathesis:evaluate(action)
  if self.cache then return self.cache end

  local arguments = {}
  for i = 1, #self.second.value do
    arguments[#arguments + 1] = self.second.value[i][1]:evaluate(action) -- #REVIEW
  end

  local first = self.first:evaluate(action)
  if type(first) == 'table' and first.condition then
    first.arguments = arguments
    self.cache = first
    return first
  elseif type(first) ~= 'function' then
    print('#TODO Eval', type(first))
    return false
  end

  return first()
end
function LeftParathesis:nud(expression, verify)
  local expr = expression()
  verify(')')
  return expr
end

local RightParathesis = Symbol({ id = ')' })
function RightParathesis:nud(expression, verify)
  return self
end

local LeftBracket = Symbol({ id = '[', lbp = 150 })
function LeftBracket:led(left, expression, verify, token)
  self.first = left
  self.second = expression(self.lbp)
  verify(']')
  return self
end
function LeftBracket:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  if not first[second] then
    print(format('Invalid key for %s: %s', first, second))
  end

  return first[second]
end
function LeftBracket:nud(expression, verify)
  local expr = expression()
  verify(']')
  return expr
end

local RightBracket = Symbol({ id = ']' })
function RightBracket:nud(expression, verify)
  return self
end

local Invert = Symbol({ id = '!', lbp = 50 })
function Invert:nud(expression, verify)
  self.first = expression(self.lbp)
  self.second = nil
  return self
end
function Invert:evaluate(action)
  return not self:eval(action)
end

local And = Symbol({ id = 'And', lbp = 40 })
function And:led(left, expression)
  self.first = left
  self.second = expression(self.lbp - 1)
  return self
end
function And:evaluate(action)
  local first = self.first:evaluate(action)
  if not first then return false end

  local second = self.second:evaluate(action)
  return first and second
end

local Or = Symbol({ id = 'Or', lbp = 30 })
function Or:led(left, expression)
  self.first = left
  self.second = expression(self.lbp - 1)
  return self
end
function Or:evaluate(action)
  local first = self.first:evaluate(action)
  if first then return first end

  local second = self.second:evaluate(action)
  return first or second
end

local Null = Symbol({ id = 'Null', lbp = 0 })
function Null:nud() error('#TYPO NULl') end

local function evaluate(rule, tokens)
  local token, ok
  local tokenLength, currentToken = #tokens, 0

  local function advance(parameter)
    currentToken = currentToken + 1
    if currentToken > tokenLength then return Null() end

    local tokenType, tokenValue = tokens[currentToken][1], tokens[currentToken][2]
    if     tokenType == 'number' then return Number({ value = tonumber(tokenValue) })
    elseif tokenType == 'constant' then return Constant({ value = tokenValue })
    elseif tokenType == 'library' then return Library({ value = tokenValue })
    -- elseif tokenType == 'identifier' then return Identifier({ value = tokenValue:match'^%s*(.*%S)' or '' })
    elseif tokenType == 'identifier' then return Identifier({ value = tokenValue })
    elseif tokenType == 'period' then return Period()
    elseif tokenType == 'string' then return String({ value = sub(tokenValue, 2, -2) })
    elseif tokenType == 'space' then
      if parameter then return Space({ value = tokenValue })
      else return advance()
      end
    elseif tokenType == 'character' then
      if parameter then return Character({ value = tokenValue })
      else return advance()
      end
    elseif tokenType == 'args' then return Args({ value = tokenValue })
    elseif tokenType == 'comma' then return Comma()
    elseif tokenType == 'logic' then
      if     tokenValue == 'and' then
        if parameter then return String({ value = 'and' })
        else return And() end
      elseif tokenValue == 'or' then return Or()
      end
    elseif tokenType == 'math' then
      if     tokenValue == '+' then return Add()
      elseif tokenValue == '-' then
        if parameter then return Dash({ value = tokenValue })
        else return Subtract() end
      elseif tokenValue == '*' then return Multiply()
      elseif tokenValue == '/' then return Divide()
      elseif tokenValue == '%' then return Modulus()
      end
    elseif tokenType == 'comparator' then
      if     tokenValue == '>' then return GreaterThan()
      elseif tokenValue == '>=' then return GreaterThanEqual()
      elseif tokenValue == '<' then return LesserThan()
      elseif tokenValue == '<=' then return LesserThanEqual()
      elseif tokenValue == '==' then return Equal()
      elseif tokenValue == '=' then return Equal()
      elseif tokenValue == '!=' then return NotEqual()
      elseif tokenValue == '~=' then return NotEqual()
      end
    elseif tokenType == 'openBracket' then return LeftBracket()
    elseif tokenType == 'closeBracket' then return RightBracket()
    elseif tokenType == 'openParen' then return LeftParathesis()
    elseif tokenType == 'closeParen' then return RightParathesis()
    elseif tokenType == 'not' then return Invert()
    else error('Unknown Operator: ' .. tokenType)
    end
  end

  local function printToken(fn)
    if #tokens == 0 then return 'Empty Rule' end

    local location = fn == 'nud' and 1 or 0

    local rule = ''
    for i = 1, tokenLength do
      if i == currentToken - location then
        rule = rule .. ' >> ' .. tokens[i][2] .. ' << '
      else
        rule = rule .. tokens[i][2]
      end
    end

    return rule
  end

  local function verify(expected)
    if expected and expected ~= token.id then
      error('Verification failed: Expected: ' .. expected .. '\nFound: ' .. token.id)
    end

    token = advance()
    return token
  end

  local function expression(rbp, ignore)
    rbp = rbp or 0

    local t = token
    token = advance(ignore)
    if not t.nud then error('No NUD on ' .. t.id) end
    ok, left = pcall(t.nud, t, expression, verify)
    if not ok then
      error(left .. '\n' .. printToken('nud'))
    end

    while rbp < token.lbp do
      t = token
      token = advance(ignore)
      if not t.led then error('No LED on ' .. t.id) end
      ok, left = pcall(t.led, t, left, expression, verify, token)
      if not ok then
        error(left .. '\n' .. printToken('led'))
      end
    end

    return left, token
  end

  token = advance()

  local left, unparsed = expression()
  if unparsed.id ~= 'Null' then
    error('Could not process complete rule\n' .. printToken('led'))
  end

  return left
end

local function parse(rule)
  local tokens, err = lexer.parse(rule, 'rule')
  if err then
    error('Could not parse: ' .. err)
  end

  return evaluate(rule, tokens)
end

if require then
  return { parse = parse }
elseif ProbablyEngine then
  ProbablyEngine.ruleParser = { parse = parse }
end
