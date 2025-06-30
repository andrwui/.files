import { bind, Variable } from 'astal'
import { password, selectedAp, wifi } from '../../variables'
import { areApsSame } from '../../helper'

const NetworkPasswordEntry = () => {
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

  return (
    <entry
      editable
      visible={!areApsSameBinding.get()}
      visibility={false}
      placeholderText={'password'}
      css={`
        border: 1px solid white;
        border-radius: 0;
        background: transparent;
      `}
      onChanged={(self) => {
        password.set(self.get_text())
        console.log(password.get())
        password.subscribe((pass) => {
          if (pass === '') {
            self.set_text('')
          }
        })
      }}
    />
  )
}

export default NetworkPasswordEntry
