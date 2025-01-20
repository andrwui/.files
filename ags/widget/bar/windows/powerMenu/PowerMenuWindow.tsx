import { App, Astal, Gdk } from "astal/gtk3"

import GenericWindow from "../_generic/GenericWindow"
import { closeAllOtherWindows } from "../../components/helper"
import { handleWindowEsc } from "../helper"
import { exec } from "astal"


const PowerMenuItem = ({ children, onClick }: { children?: JSX.Element | JSX.Element[]; onClick: () => string }) => {

  return <eventbox
    hexpand
    clickThrough={false}
    onClick={onClick}
    width_request={200}
    margin={10}
    css={'font-size: 20px;'}

  >
    {children}
  </eventbox>
}


export const PowerMenuWindowNamePrefix = 'powerMenu'

const PowerMenuWindow = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const windowName = `${PowerMenuWindowNamePrefix}-${monitorIndex}`

  const { TOP, LEFT, BOTTOM, RIGHT } = Astal.WindowAnchor


  return <window
    visible={false}
    gdkmonitor={monitor}
    name={windowName}
    application={App}
    anchor={TOP | LEFT | BOTTOM | RIGHT}
    css={'background: transparent;'}
    onKeyPressEvent={handleWindowEsc}
    keymode={Astal.Keymode.EXCLUSIVE}
  >
    <eventbox
      css={'background: rgba(0, 0, 0, 0.5);'}
      onClick={() => {
        closeAllOtherWindows("")
      }}

    >

      <box
        margin_left={600}
        margin_right={600}
        margin_top={400}
        margin_bottom={400}
        clickThrough={false}
        className={'window'}
      >
        <PowerMenuItem
          onClick={() => exec("poweroff")}
        >
          <label
            label={'[poweroff]'}
            className={'window'}
            hexpand
          />
          <></>
        </PowerMenuItem>
        <PowerMenuItem
          onClick={() => exec("swaylock")}
        >
          <label
            label={'[lock]'}
            className={'window'}
            hexpand
          />
          <></>
        </PowerMenuItem>
      </box>


    </eventbox>

  </window>
}

export default PowerMenuWindow
