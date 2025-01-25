import { bind, Variable } from 'astal'
import { App } from 'astal/gtk3'
import AstalNetwork from 'gi://AstalNetwork'

export const wifi = AstalNetwork.get_default().wifi
export const selectedAp = Variable<AstalNetwork.AccessPoint | null>(null)

export const password = Variable<string>('')
Variable.derive([selectedAp], () => {
  password.set('')
})

const wifiBinding = Variable<[AstalNetwork.AccessPoint[], AstalNetwork.AccessPoint] | [null, null]>(
  [null, null],
)
Variable.derive([bind(wifi, 'accessPoints'), bind(wifi, 'activeAccessPoint')], (aps, activeAp) => {
  wifiBinding.set([aps, activeAp])
})
