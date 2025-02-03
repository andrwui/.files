import { App } from 'astal/gtk3'
import { HyprWindowNamePrefix } from '../windows/hypr/HyprWindow'
import { closeAllOtherWindows } from './helper'

type HyprsourcesProps = {
  monitorIndex: number
}

const Hyprsources = ({ monitorIndex }: HyprsourcesProps) => {
  const windowName = `${HyprWindowNamePrefix}-${monitorIndex}`

  App.add_icons('/home/andrw/.files/ags/icons')
  return (
    <eventbox onClick={() => closeAllOtherWindows(windowName)}>
      <icon icon={'hyprland-symbolic'} />
    </eventbox>
  )
}

export default Hyprsources
