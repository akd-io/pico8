function generateItem()
  local equipmentType = rnd(itemTypes)
  local availableAffixesBag = shallowCopy(affixTypeKeys)
  local numAffixes = ceil(rnd(maxAffixesPerItem))
  local affixes = {}
  for i = 1, numAffixes do
    local affixType = rnd(availableAffixesBag)
    local tier = rnd(affixTiers)
    affixes[affixType] = tier
    del(availableAffixesBag, affixType)
  end
  return {
    equipmentType = equipmentType,
    affixes = affixes
  }
end