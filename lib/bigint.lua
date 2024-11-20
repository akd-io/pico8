local BigInteger = {}
BigInteger.__index = BigInteger

function BigInteger.new(value)
  local self = setmetatable({}, BigInteger)
  if type(value) == "string" then
    self.digits = {}
    for i = #value, 1, -1 do
      table.insert(self.digits, tonumber(value:sub(i, i)))
    end
  elseif type(value) == "number" then
    self.digits = {}
    while value > 0 do
      table.insert(self.digits, value % 10)
      value = math.floor(value / 10)
    end
  else
    error("Invalid input type for BigInteger")
  end
  self:removeLeadingZeros()
  return self
end

function BigInteger:removeLeadingZeros()
  while #self.digits > 1 and self.digits[#self.digits] == 0 do
    table.remove(self.digits)
  end
end

function BigInteger:toString()
  local result = ""
  for i = #self.digits, 1, -1 do
    result = result .. tostring(self.digits[i])
  end
  return #result > 0 and result or "0"
end

function BigInteger:add(other)
  local result = BigInteger.new("0")
  local carry = 0
  local i = 1
  while i <= #self.digits or i <= #other.digits or carry > 0 do
    local sum = (self.digits[i] or 0) + (other.digits[i] or 0) + carry
    result.digits[i] = sum % 10
    carry = math.floor(sum / 10)
    i = i + 1
  end
  result:removeLeadingZeros()
  return result
end

function BigInteger:multiply(other)
  local result = BigInteger.new("0")
  for i = 1, #self.digits do
    local partial = BigInteger.new("0")
    local carry = 0
    for j = 1, #other.digits do
      local prod = self.digits[i] * other.digits[j] + carry
      partial.digits[i + j - 1] = prod % 10
      carry = math.floor(prod / 10)
    end
    if carry > 0 then
      partial.digits[i + #other.digits] = carry
    end
    result = result:add(partial)
  end
  result:removeLeadingZeros()
  return result
end

function BigInteger:divMod(divisor)
  if divisor:toString() == "0" then
    error("Division by zero")
  end
  local quotient = BigInteger.new("0")
  local remainder = BigInteger.new("0")
  for i = #self.digits, 1, -1 do
    remainder = remainder:multiply(BigInteger.new("10"))
    remainder = remainder:add(BigInteger.new(tostring(self.digits[i])))
    local digit = 0
    while BigInteger.new(tostring(digit + 1)):multiply(divisor):toString() <= remainder:toString() do
      digit = digit + 1
    end
    quotient = quotient:multiply(BigInteger.new("10")):add(BigInteger.new(tostring(digit)))
    remainder = remainder:add(BigInteger.new(tostring(-digit)):multiply(divisor))
  end
  quotient:removeLeadingZeros()
  remainder:removeLeadingZeros()
  return quotient, remainder
end

function BigInteger:divide(other)
  local quotient, _ = self:divMod(other)
  return quotient
end

function BigInteger:mod(other)
  local _, remainder = self:divMod(other)
  return remainder
end

function BigInteger:remainder(other)
  return self:mod(other)
end

return BigInteger