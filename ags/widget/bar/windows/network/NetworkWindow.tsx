import { Gdk } from 'astal/gtk3'

export const NetworkWindowNamePrefix = 'networkWindow'

const NetworkWindow = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const windowName = `${NetworkWindowNamePrefix}-${monitorIndex}`

  return <></>
}

export default NetworkWindow
