const tsSource = App.configDir + '/main.ts'
const jsOutdir = '/tmp/ags/js'

try {
  //@ts-ignore
  await Utils.execAsync([
    'bun', 'build', tsSource,
    '--outdir', jsOutdir,
    '--external', 'resource://*',
    '--external', 'gi://*',
  ])
  //@ts-ignore

  await import(`file://${jsOutdir}/main.js`)
} catch (error) {
  console.error(error)
}