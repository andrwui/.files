import { HeadLayout } from '../ActionBarHead'
import { Gtk } from 'astal/gtk3'
import SimpleClock from '@/widget/generic/SimpleClock'
export default function ActionBarHeadNormalLayout() {
  return (
    <box
      name={HeadLayout.NORMAL}
      halign={Gtk.Align.CENTER}
    >
      <SimpleClock />
    </box>
  )
}
