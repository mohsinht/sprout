export function compareNavs(primary: number, validation: number, tolerance = 0.005) {
  const differenceRatio = Math.abs(primary - validation) / primary;
  return { differenceRatio, matched: differenceRatio <= tolerance };
}
