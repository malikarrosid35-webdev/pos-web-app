export const formatNumber = (num) => {
  const number = typeof num === "string" ? parseFloat(num) : num;
  if (isNaN(number)) return "0";

  const parts = number.toFixed(2).split(".");
  let integerPart = parts[0];
  let decimalPart = parts[1];

  integerPart = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, ".");

  if (decimalPart === "00") {
    return integerPart;
  }

  return `${integerPart},${decimalPart}`;
};

export const parseNumber = (str) => {
  const cleaned = str.replace(/\./g, "").replace(",", ".");
  const parsed = parseFloat(cleaned);
  return isNaN(parsed) ? 0 : parsed;
};

export const formatToRupiah = (num) => {
  return `Rp${formatNumber(num)}`;
};
