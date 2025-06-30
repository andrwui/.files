import { bind, Variable } from 'astal'
import { selectedAp, wifi } from '../../variables'
import { areApsSame, connect, disconnect } from '../../helper'

const areApsSameBinding = Variable<boolean>(false)
Variable.derive([bind(selectedAp), bind(wifi, 'activeAccessPoint')], (sap, aap) => {
  if (!aap) {
    areApsSameBinding.set(false)
  } else {
    if (sap) {
      areApsSameBinding.set(areApsSame(sap, aap))
    }
  }
})

const NetworkConnectButton = () => {
  const handleClick = () => {
    if (areApsSameBinding.get()) {
      disconnect()
    } else {
      connect()
    }
    selectedAp.set(null)
  }

  return (
    <eventbox
      cursor="pointer"
      heightRequest={50}
      onClick={handleClick}
      css={`
        border: 1px solid white;
      `}
    >
      {areApsSameBinding.get() ? 'disconnect' : 'connect'}
    </eventbox>
  )
}

export default NetworkConnectButton
