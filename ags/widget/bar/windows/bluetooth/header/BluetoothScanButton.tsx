import { bind, timeout, Variable } from 'astal'
import AstalBluetooth from 'gi://AstalBluetooth?version=0.1'
import GenericTextButton from '../../_generic/GenericTextButton'

const BluetoothScanButton = () => {
  const bt = AstalBluetooth.get_default()

  const isDiscovering: Variable<boolean> = Variable(false)
  let discoveringBinding: Variable<void> | undefined

  Variable.derive([bind(bt, 'adapter')], () => {
    discoveringBinding?.drop()
    discoveringBinding = undefined

    if (!bt.adapter) {
      return
    }

    discoveringBinding = Variable.derive([bind(bt.adapter, 'discovering')], (discovering) => {
      isDiscovering.set(discovering)
    })
  })

  {
    return (
      <GenericTextButton
        onClick={() => {
          if (bt.adapter?.discovering) {
            return bt.adapter.stop_discovery()
          }

          bt.adapter?.start_discovery()

          const to = 10000

          timeout(to, () => {
            if (bt.adapter?.discovering) {
              return bt.adapter.stop_discovery()
            }
          })
        }}
      >
        {bind(bt.adapter, 'discovering').as((isDiscovering) => {
          return `[${isDiscovering ? 'stop scan' : 'scan'}]`
        })}
      </GenericTextButton>
    )
  }
}

export default BluetoothScanButton
