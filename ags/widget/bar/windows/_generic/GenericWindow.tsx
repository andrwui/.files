import { Astal, App, Gtk, Widget } from 'astal/gtk3'
import { handleWindowEsc } from '../helper'

interface WindowProps extends Widget.WindowProps {
  children?: JSX.Element | JSX.Element[]
  boxProps?: Widget.BoxProps
}

const GenericWindow = ({ children, boxProps, ...props }: WindowProps) => {
  const { TOP, RIGHT } = Astal.WindowAnchor

  return (
    <window
      exclusivity={Astal.Exclusivity.NORMAL}
      application={App}
      layer={Astal.Layer.TOP}
      visible={false}
      anchor={TOP | RIGHT}
      margin={15}
      keymode={Astal.Keymode.ON_DEMAND}
      onKeyPressEvent={handleWindowEsc}
      {...props}
    >
      <box
        hexpand
        vertical
        className="window"
        halign={Gtk.Align.FILL}
        {...boxProps}
      >
        {children}
      </box>
    </window>
  )
}

export default GenericWindow
