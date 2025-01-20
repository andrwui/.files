import { Astal, App, Gtk, Widget } from 'astal/gtk3'
import { handleWindowEsc } from '../helper'

interface WindowProps extends Widget.WindowProps {
  children?: JSX.Element | JSX.Element[]
}

const GenericWindow = ({ children, ...props }: WindowProps) => {
  const { TOP, RIGHT } = Astal.WindowAnchor

  return (
    <window
      exclusivity={Astal.Exclusivity.NORMAL}
      application={App}
      layer={Astal.Layer.TOP}
      visible={false}
      anchor={TOP | RIGHT}
      margin={15}
      keymode={Astal.Keymode.NONE}
      onKeyPressEvent={handleWindowEsc}
      {...props}
    >
      <box
        hexpand
        vertical
        className="window"
        halign={Gtk.Align.FILL}
      >
        {children}
      </box>
    </window>
  )
}

export default GenericWindow
