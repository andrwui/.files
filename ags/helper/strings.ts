export function truncateText(str: string, maxLength: number) {
  if (str.length > maxLength) {
    const truncatedLength = maxLength - 3
    return str.slice(0, truncatedLength) + '...'
  } else {
    return str
  }
}
