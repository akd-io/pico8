# RPG by akd

## How to store an rpg character in 256 bytes?

Powers of 2 lookup table for convenience:
1 bit: 2^1 = 2
2 bits: 2^2 = 4
3 bits: 2^3 = 8
4 bits: 2^4 = 16
5 bits: 2^5 = 32
6 bits: 2^6 = 64
7 bits: 2^7 = 128
1 byte: 2^8 = 255
2 bytes: 2^16 = 65,536
3 bytes: 2^24 = 16,777,216
4 bytes: 2^32 = 4,294,967,296
5 bytes: 2^40 = 1,099,511,627,776
6 bytes: 2^48 = 281,474,976,710,656
7 bytes: 2^56 = 72,057,594,037,927,936
8 bytes: 2^64 = 18,446,744,073,709,551,616

### Experience points - 4 bytes - 4/256

Experience points can be implemented as a 32-bit integer to leave room for exp gain scaling throughout the levels.

EXPERIENCE POINTS: 4 bytes
TALLY: 4/256

### Skill points - 12 bytes - 16/256

Skill points can be saved as a bit field. If the game has say 96 skill points, that's a 96-bit bit field.

SKILL POINTS: 12 bytes
TALLY: 16/256 (previous 4 + 12 = 16)

### Items

Sample item:

- Strong boots of haste (Magic, 2 affixes)
- T2 Str: +4 Strength
- T3 Agility: +6% Movement speed

Assuming a pool of 16 affix types, each item having up to 8 of these affixes in tier 1-16, an item could be coded as follows:

- 4: 4-bit integer specifying the slot type
- 16: 16-bit bit field specifying the affix types
- 24: 6 4-bit integers specifying the tier (1-16) of each of the max 6 affix types that can be present on an item at once.

This results in 44 bits or 5.5 bytes per item.

Items can reside in the characters equipment slots, or in its inventory. Those will be described in detail in their own sections below.

#### Equipment - 50 bytes - 66/256

As each equipment slot can only hold a single slot type, the position of each character equipment slot can be fixed in memory, such that we don't need to explicitly store the item's slot type.

This saves 4 bits equipment slot, leaving us at 40 bits or 5 bytes per equipment slot.

With 10 equipment slots, (main hand, off hand, head, neck, body, waist, legs, feet, hands, finger)
that makes 10 x 5 bytes = 50 bytes used to store equipment.

EQUIPMENT: 50 bytes (10 items x 5 bytes/slot)
TALLY: 66/256 (previous 16 + 50 = 66)

#### Inventory - 110 bytes - 176/256

It would be nice to have inventory at least double that.

When saving inventory, we cannot make the same assumption about slot types, and need to save that with the item, using the original 44 bits or 5.5 bytes per item.

INVENTORY: 110 bytes (20 items x 5.5 bytes/item)
TALLY: 176/256 (previous 66 + 110 = 176)

### World progress - 4 bits - 176.5/256

Maybe we are missing some world progress data?
We could use a 4 bit integer to represent completion of 16 levels.

WORLD PROGRESS: 4 bits (0.5 bytes)
TALLY: 176.5/256 (previous 176 + 0.5 = 176.5)

### Character creation

We could use some of the last space to store the results of a character creation screen.

### Future improvements

#### Item space improvements

If space becomes an issue, it's possible to decrease the space per item to any arbitrary number of bits.

This can be done by not saving the item stats directly, but instead a random seed that generated the item, using a custom seed-to-item generation function.

This will decrease the space of possible items that can be generated, but users won't notice or care that some affix combinations don't exist in the vast majority of cases.

The exception being end-game items. We would need to make sure that a range of the seed-interval be set aside to support every T96 item (every combination of 6 T16 affixes).
