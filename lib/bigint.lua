function create_bigint(value)
  local self = {}
  self.digits = {}
  if type(value) == "string" then
    for i = #value, 1, -1 do
      add(self.digits, tonum(sub(value, i, i)))
    end
  elseif type(value) == "number" then
    while value > 0 do
      add(self.digits, value % 10)
      value = flr(value / 10)
    end
  else
    assert(false, "invalid input type for bigint")
  end
  return self
end

function bigint_tostring(self)
  local result = ""
  for i = #self.digits, 1, -1 do
    result = result .. tostr(self.digits[i])
  end
  return #result > 0 and result or "0"
end

function bigint_add(a, b)
  local result = create_bigint("0")
  local carry = 0
  local i = 1
  while i <= #a.digits or i <= #b.digits or carry > 0 do
    local sum = (a.digits[i] or 0) + (b.digits[i] or 0) + carry
    result.digits[i] = sum % 10
    carry = flr(sum / 10)
    i = i + 1
  end
  return result
end

function bigint_multiply(a, b)
  local result = create_bigint("0")
  for i = 1, #a.digits do
    local partial = create_bigint("0")
    local carry = 0
    for j = 1, #b.digits do
      local prod = a.digits[i] * b.digits[j] + carry
      partial.digits[i + j - 1] = prod % 10
      carry = flr(prod / 10)
    end
    if carry > 0 then
      partial.digits[i + #b.digits] = carry
    end
    result = bigint_add(result, partial)
  end
  return result
end

function bigint_compare(a, b)
  if #a.digits > #b.digits then return 1 end
  if #a.digits < #b.digits then return -1 end
  for i = #a.digits, 1, -1 do
    if a.digits[i] > b.digits[i] then return 1 end
    if a.digits[i] < b.digits[i] then return -1 end
  end
  return 0
end

function bigint_subtract(a, b)
  local result = create_bigint("0")
  local borrow = 0
  for i = 1, #a.digits do
    local diff = a.digits[i] - (b.digits[i] or 0) - borrow
    if diff < 0 then
      diff += 10
      borrow = 1
    else
      borrow = 0
    end
    result.digits[i] = diff
  end
  while #result.digits > 1 and result.digits[#result.digits] == 0 do
    result.digits[#result.digits] = nil
  end
  return result
end

function bigint_divmod(a, b)
  assert(bigint_tostring(b) != "0", "division by zero")
  local quotient = create_bigint("0")
  local remainder = create_bigint("0")
  for i = #a.digits, 1, -1 do
    remainder = bigint_multiply(remainder, create_bigint("10"))
    remainder = bigint_add(remainder, create_bigint(tostr(a.digits[i])))
    local digit = 0
    while bigint_compare(bigint_multiply(create_bigint(tostr(digit + 1)), b), remainder) <= 0 do
      digit += 1
    end
    quotient = bigint_add(bigint_multiply(quotient, create_bigint("10")), create_bigint(tostr(digit)))
    remainder = bigint_subtract(remainder, bigint_multiply(create_bigint(tostr(digit)), b))
  end
  return quotient, remainder
end

function bigint_divide(a, b)
  local quotient, _ = bigint_divmod(a, b)
  return quotient
end

function bigint_mod(a, b)
  local _, remainder = bigint_divmod(a, b)
  return remainder
end

function bigint_remainder(a, b)
  return bigint_mod(a, b)
end