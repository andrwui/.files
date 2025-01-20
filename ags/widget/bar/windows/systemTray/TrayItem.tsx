import AstalTray from 'gi://AstalTray'

import { handleTrayItemClick } from './helper'
import { Gtk } from 'astal/gtk3'

const TrayItem = ({ item, menu }: { item: AstalTray.TrayItem; menu: Gtk.Menu | null }) => {
  return (
    <eventbox onClick={(self, event) => handleTrayItemClick(self, event, item, menu)}>
      <icon gIcon={item.get_gicon()} />
    </eventbox>
  )
}

export default TrayItem
