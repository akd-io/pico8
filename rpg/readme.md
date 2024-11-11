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

##### Sample seed-based item generation and storage

For fun, let's see what we would be looking at.

First, let's reiterate the original item scheme:

44 bits (5.5 bytes) per item:

- 4: 4-bit integer specifying the slot type
- 16: 16-bit bit field specifying the affix types
- 24: 6 4-bit integers specifying the tier (1-16) of each of the max 6 affix types that can be present on an item at once.

Say we want to decrease the size to 32 bits (4 bytes), the naive implementation is just a 4 byte hash.

Let's say we want to make sure there is an equal amount of items tier 1-16.

We can do this by turning the 32-bit unsigned integer's 4,294,967,296 seeds into 16 ranges:

Note: The tier of an item is the floor of the average of the affix tiers. The flooring makes tiers start at 0 and tier 16s is very rare.

| From       | To         | Tier  | Interval size |
| ---------- | ---------- | ----- | ------------- |
| 0          | 268435456  | 0-1   | 268435456     |
| 268435456  | 536870912  | 1-2   | 268435456     |
| 536870912  | 805306368  | 2-3   | 268435456     |
| 805306368  | 1073741824 | 3-4   | 268435456     |
| 1073741824 | 1342177280 | 4-5   | 268435456     |
| 1342177280 | 1610612736 | 5-6   | 268435456     |
| 1610612736 | 1879048192 | 6-7   | 268435456     |
| 1879048192 | 2147483648 | 7-8   | 268435456     |
| 2147483648 | 2415919104 | 8-9   | 268435456     |
| 2415919104 | 2684354560 | 9-10  | 268435456     |
| 2684354560 | 2952790016 | 10-11 | 268435456     |
| 2952790016 | 3221225472 | 11-12 | 268435456     |
| 3221225472 | 3489660928 | 12-13 | 268435456     |
| 3489660928 | 3758096384 | 13-14 | 268435456     |
| 3758096384 | 4026531840 | 14-15 | 268435456     |
| 4026531840 | 4294967296 | 15-16 | 268435456     |

Each of these ranges is equal in size, but we could just as well have made them different sizes to allocate more or less seed space to the different tiers. We can also subdivide these ranges into more ranges. For example, we could split tier 1's range from 0 to 268435456 into 16 new ranges, each range for a specific item type. More creatively perhaps, a new layer of 16 ranges could provide certainty for each affix type to be present on the item.

What we're looking to do now, however, is replace the 16th tier range with the full range necessary to represent all T16 items, as we want all end-game items to be available.

Let's take the original item byte packing overview, and remove the tiers.

- We still need slot type:
  - 4: 4-bit integer specifying the slot type
- We still need affix types:
  - 16: 16-bit bit field specifying the affix types
- We no longer need affix tiers:
  - ~24: 6 4-bit integers specifying the tier (1-16) of each of the max 6 affix types that can be present on an item at once.~

This makes all T16 items fit in just 20 bits (2.5 bytes). That means that the number of combination is only 2^20 = 1.048.576. That is only ~0,0244% (2^20/2^32) of the proposed seed-based 32-bit item size. This means we can shrink and shift the seed ranges for each tier, such that the first 1.048.576 seeds will store T16 item combinations, leaving 4.293.918.720 (2^32-2^20) seeds to remain procedurally generated.

| From       | To         | Tier | Interval size |
| ---------- | ---------- | ---- | ------------- |
| 0          | 1048576    | 16   | 1048576       |
| 1048576    | 269418496  | 0    | 268369920     |
| 269418496  | 537788416  | 1    | 268369920     |
| 537788416  | 806158336  | 2    | 268369920     |
| 806158336  | 1074528256 | 3    | 268369920     |
| 1074528256 | 1342898176 | 4    | 268369920     |
| 1342898176 | 1611268096 | 5    | 268369920     |
| 1611268096 | 1879638016 | 6    | 268369920     |
| 1879638016 | 2148007936 | 7    | 268369920     |
| 2148007936 | 2416377856 | 8    | 268369920     |
| 2416377856 | 2684747776 | 9    | 268369920     |
| 2684747776 | 2953117696 | 10   | 268369920     |
| 2953117696 | 3221487616 | 11   | 268369920     |
| 3221487616 | 3489857536 | 12   | 268369920     |
| 3489857536 | 3758227456 | 13   | 268369920     |
| 3758227456 | 4026597376 | 14   | 268369920     |
| 4026597376 | 4294967296 | 15   | 268369920     |
