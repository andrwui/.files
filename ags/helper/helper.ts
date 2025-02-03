export const chunk = <T>(arr: T[], size: number): T[][] =>
  arr.reduce((acc: T[][], _, i) => {
    if (i % size === 0) {
      acc.push(arr.slice(i, i + size))
    }
    return acc
  }, [])

export const truncate = (str: string, len: number): string => {
  if (str.length < len) {
    return str
  }

  return `${str.slice(0, len).trim()}...`
}
