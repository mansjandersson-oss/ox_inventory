import { CaseReducer, PayloadAction } from '@reduxjs/toolkit';
import { getTargetInventory } from '../helpers';
import { Inventory, InventoryType, SlotWithItem, State } from '../typings';
import { Items } from '../store/items';

export const stackSlotsReducer: CaseReducer<
  State,
  PayloadAction<{
    fromSlot: SlotWithItem;
    fromType: Inventory['type'];
    toSlot: SlotWithItem;
    toType: Inventory['type'];
    count: number;
  }>
> = (state, action) => {
  const { fromSlot, fromType, toSlot, toType, count } = action.payload;

  const { sourceInventory, targetInventory } = getTargetInventory(state, fromType, toType);

  const pieceWeight = fromSlot.weight / fromSlot.count;
  const sourceItemData = Items[fromSlot.name];
  const maxStack = typeof sourceItemData?.stack === 'number' ? sourceItemData.stack : null;
  const actualCount = maxStack ? Math.min(count, maxStack - (toSlot.count ?? 0)) : count;

  if (actualCount <= 0) return;

  targetInventory.items[toSlot.slot - 1] = {
    ...targetInventory.items[toSlot.slot - 1],
    count: toSlot.count + actualCount,
    weight: pieceWeight * (toSlot.count + actualCount),
  };

  if (fromType === InventoryType.SHOP || fromType === InventoryType.CRAFTING) return;

  sourceInventory.items[fromSlot.slot - 1] =
    fromSlot.count - actualCount > 0
      ? {
          ...sourceInventory.items[fromSlot.slot - 1],
          count: fromSlot.count - actualCount,
          weight: pieceWeight * (fromSlot.count - actualCount),
        }
      : {
          slot: fromSlot.slot,
        };
};
