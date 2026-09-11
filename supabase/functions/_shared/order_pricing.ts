/** Canonical Quran order prices in pence (GBP).
 * Keep in sync with lib/core/services/order_pricing.dart
 *
 * Rows: [quantity, costPence, postagePence]
 */
export type OrderPackKind = "copies" | "boxes";

export type OrderPriceQuote = {
  kind: OrderPackKind;
  quantity: number;
  quranCount: number;
  costPence: number;
  postagePence: number;
  totalPence: number;
};

export const COPIES: ReadonlyArray<readonly [number, number, number]> = [
  [1, 0, 750],
  [2, 1000, 250],
  [3, 1300, 200],
  [4, 1300, 200],
  [5, 1500, 250],
  [6, 1800, 200],
  [7, 1800, 200],
  [8, 1800, 200],
  [9, 1800, 200],
];

export const BOXES: ReadonlyArray<readonly [number, number, number]> = [
  [1, 2000, 500],
  [2, 2500, 500],
  [3, 3000, 500],
  [4, 4000, 500],
  [5, 4500, 1000],
  [6, 5000, 1500],
  [7, 5500, 2000],
  [8, 6000, 2500],
  [9, 6500, 3000],
  [10, 7000, 3500],
  [11, 10000, 5000],
  [12, 12000, 6000],
  [13, 13000, 7500],
  [14, 14000, 8500],
  [15, 16000, 10000],
];

const COPIES_PER_BOX = 10;

export function parsePackKind(raw: unknown): OrderPackKind | null {
  if (raw === "copies" || raw === "boxes") return raw;
  return null;
}

export function quoteOrder(kind: OrderPackKind, quantity: number): OrderPriceQuote | null {
  if (!Number.isInteger(quantity)) return null;
  const rows = kind === "copies" ? COPIES : BOXES;
  const row = rows.find((r) => r[0] === quantity);
  if (!row) return null;
  const costPence = row[1];
  const postagePence = row[2];
  return {
    kind,
    quantity,
    quranCount: kind === "boxes" ? quantity * COPIES_PER_BOX : quantity,
    costPence,
    postagePence,
    totalPence: costPence + postagePence,
  };
}
