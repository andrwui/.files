export const chunk = <T>(arr: T[], size: number): T[][] =>
  arr.reduce((acc: T[][], _, i) => {

    if (i % size === 0) {
      acc.push(arr.slice(i, i + size))
    }
    return acc
  }, [])
