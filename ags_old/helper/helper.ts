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

export const wrap = (str: string, wpp: number): string => {
  const words = str.split(' ')

  const lines: string[] = []

  for (let i = 0; i < words.length; i += wpp) {
    lines.push(words.slice(i, i + wpp).join(' '))
  }

  return lines.join('\n')
}
