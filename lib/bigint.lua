-- Helper function to create a new BigInteger
function bi_new(n)
  local bi = { sign = 1, digits = {} }
  if type(n) == "number" then
    if n < 0 then
      bi.sign = -1
      n = -n
    end
    while n > 0 do
      add(bi.digits, n % 10)
      n = flr(n / 10)
    end
  elseif type(n) == "string" then
    if sub(n, 1, 1) == "-" then
      bi.sign = -1
      n = sub(n, 2)
    end
    for i = #n, 1, -1 do
      add(bi.digits, tonum(sub(n, i, i)))
    end
  end
  if #bi.digits == 0 then add(bi.digits, 0) end
  return bi
end

-- Helper function to remove leading zeros
function bi_trim_zeros(bi)
  while #bi.digits > 1 and bi.digits[#bi.digits] == 0 do
    deli(bi.digits, #bi.digits)
  end
  if #bi.digits == 1 and bi.digits[1] == 0 then
    bi.sign = 1
  end
end

-- Helper function to compare absolute values
function bi_abs_compare(a, b)
  if #a.digits > #b.digits then return 1 end
  if #a.digits < #b.digits then return -1 end
  for i = #a.digits, 1, -1 do
    if a.digits[i] > b.digits[i] then return 1 end
    if a.digits[i] < b.digits[i] then return -1 end
  end
  return 0
end

-- Addition operation
function bi_add(a, b)
  local result = bi_new(0)
  local carry = 0
  local i = 1
  local a_len, b_len = #a.digits, #b.digits
  local max_len = max(a_len, b_len)

  if a.sign == b.sign then
    -- Simple addition
    while i <= max_len or carry > 0 do
      local sum = carry
      if i <= a_len then sum += a.digits[i] end
      if i <= b_len then sum += b.digits[i] end
      carry = flr(sum / 10)
      result.digits[i] = sum % 10
      i += 1
    end
    result.sign = a.sign
  else
    -- Subtraction
    local larger, smaller
    if bi_abs_compare(a, b) >= 0 then
      larger, smaller = a, b
      result.sign = a.sign
    else
      larger, smaller = b, a
      result.sign = b.sign
    end

    while i <= max_len do
      local diff = (larger.digits[i] or 0) - (smaller.digits[i] or 0) - carry
      if diff < 0 then
        diff += 10
        carry = 1
      else
        carry = 0
      end
      result.digits[i] = diff
      i += 1
    end
  end

  bi_trim_zeros(result)
  return result
end

-- Improved multiplication operation
function bi_multiply(a, b)
  local result = bi_new(0)
  result.digits = {}

  for i = 1, #a.digits + #b.digits do
    result.digits[i] = 0
  end

  for i = 1, #a.digits do
    local carry = 0
    for j = 1, #b.digits do
      local index = i + j - 1
      local prod = result.digits[index] + a.digits[i] * b.digits[j] + carry
      result.digits[index] = prod % 10
      carry = flr(prod / 10)
    end
    if carry > 0 then
      result.digits[i + #b.digits] += carry
    end
  end

  result.sign = a.sign * b.sign
  bi_trim_zeros(result)
  return result
end

-- Improved division operation
function bi_divide(a, b)
  if #b.digits == 1 and b.digits[1] == 0 then
    error("division by zero")
  end

  -- Check if a < b
  if bi_abs_compare(a, b) < 0 then
    return bi_new(0), a
  end

  local quotient = bi_new(0)
  local remainder = bi_new(0)

  for i = #a.digits, 1, -1 do
    -- Shift remainder left by 1 digit and add current digit of a
    remainder = bi_multiply(remainder, bi_new(10))
    remainder = bi_add(remainder, bi_new(a.digits[i]))

    -- Find the largest digit q such that b * q <= remainder
    local q = 0
    while bi_abs_compare(bi_multiply(b, bi_new(q + 1)), remainder) <= 0 do
      q += 1
    end

    -- Subtract b * q from remainder
    remainder = bi_add(remainder, bi_multiply(b, bi_new(-q)))

    -- Add q to the quotient
    quotient = bi_add(bi_multiply(quotient, bi_new(10)), bi_new(q))
  end

  quotient.sign = a.sign * b.sign
  remainder.sign = a.sign
  bi_trim_zeros(quotient)
  bi_trim_zeros(remainder)
  return quotient, remainder
end

-- Helper function to convert BigInteger to string
function bi_tostring(bi)
  local str = ""
  for i = #bi.digits, 1, -1 do
    str = str .. bi.digits[i]
  end
  if bi.sign < 0 then str = "-" .. str end
  return str
end