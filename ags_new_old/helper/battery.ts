export function getBatteryIcon(percentage: number) {
  console.log(percentage)
  const p = percentage * 100
  if (p >= 90) {
    return 'i-battery-full'
  }
  if (p >= 50) {
    return 'i-battery-med'
  }
  if (p >= 20) {
    return 'i-battery-low'
  }

  return 'i-battery-empty'
}
