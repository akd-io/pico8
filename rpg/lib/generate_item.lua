function generateItem()
  local equipment_type = rnd(item_types)
  local availableAffixesBag = shallow_copy(affix_type_keys)
  local numAffixes = ceil(rnd(max_affixes_per_item))
  local affixes = {}
  for i = 1, numAffixes do
    local affix_type = rnd(availableAffixesBag)
    local tier = rnd(affix_tiers)
    affixes[affix_type] = tier
    del(availableAffixesBag, affix_type)
  end
  return {
    equipment_type = equipment_type,
    affixes = affixes
  }
end