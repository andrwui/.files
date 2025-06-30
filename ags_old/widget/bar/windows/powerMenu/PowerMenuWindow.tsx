import { App, Astal, Gdk, Gtk } from 'astal/gtk3'

import GenericWindow from '../_generic/GenericWindow'
import { closeAllOtherWindows } from '../../bar_items/helper'
import { handleWindowEsc } from '../helper'
import { exec } from 'astal'

const PowerMenuItem = ({
  children,
  onClick,
}: {
  children?: JSX.Element | JSX.Element[]
  onClick: () => string
}) => {
  return (
    <eventbox
      hexpand
      clickThrough={false}
      onClick={onClick}
      width_request={200}
      margin={10}
      css={'font-size: 20px;'}
    >
      {children}
    </eventbox>
  )
}

export const PowerMenuWindowNamePrefix = 'powerMenu'

const PowerMenuWindow = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const windowName = `${PowerMenuWindowNamePrefix}-${monitorIndex}`

  const { TOP, LEFT, BOTTOM, RIGHT } = Astal.WindowAnchor

  return (
    <GenericWindow
      gdkmonitor={monitor}
      name={windowName}
      layer={Astal.Layer.TOP}
      anchor={TOP | LEFT | BOTTOM | RIGHT}
      css={'background: transparent;'}
      margin={0}
      boxProps={{
        margin: 0,
        css: `background: transparent;
              border: none;
              padding: 0;
        `,
      }}
    >
      <eventbox
        css={`
          background: rgba(0, 0, 0, 0.5);
        `}
        vexpand
        margin={0}
        onClick={() => {
          closeAllOtherWindows('')
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
          <PowerMenuItem onClick={() => exec('poweroff')}>
            <icon
              icon={'power'}
              css="font-size: 30px;"
              className="window"
            />
            <></>
          </PowerMenuItem>
          <PowerMenuItem onClick={() => exec('swaylock')}>
            <icon
              icon={'lock-c'}
              css="font-size: 30px;"
              className="window"
            />
            <></>
          </PowerMenuItem>
        </box>
      </eventbox>
      <></>
    </GenericWindow>
  )
}

export default PowerMenuWindow
