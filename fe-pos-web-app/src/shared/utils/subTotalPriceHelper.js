export const roundKasirGramSubtotal = (value) => {
  const num = Math.round(Number(value) || 0);

  if (num <= 0) return 0;

  const base = 500;

  if (num % base === 0) return num;

  return Math.ceil(num / base) * base;
};