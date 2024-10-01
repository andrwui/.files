interface NetworkInfo {
  ethernet: {
    isConnected: boolean
  },
  wifi: {
    isConnected: boolean,
    name: string,
    availableNetworks: string[],
  }
}

class IWDService extends Service {
  static {
    Service.register(

      this,
      {
        'connection-changed': ['boolean'],
      },
      {
        'network-info': ['jsobject', 'r'],
      },
    )
  }

  #networkInfo: NetworkInfo = this.updateNetworkInfo()

  get network_info() {
    return this.updateNetworkInfo()
  }

  constructor() {
    super()

    Utils.interval(1000, () => {
      const newNetworkInfo = this.updateNetworkInfo()

      this.#networkInfo = newNetworkInfo
      this.changed('network-info')
      this.emit('connection-changed', true)
    })


  }


  updateNetworkInfo() {

    let networkInfo = {
      ethernet: {
        isConnected: false,
      },
      wifi: {
        isConnected: false,
        name: '',
        availableNetworks: [],
      },
    } as NetworkInfo

    const ethInfoLines = Utils.exec('networkctl status enp0s31f6').split('\n').map(l => l.trim())
    const wlanInfoLines = Utils.exec('iwctl station wlan0 show').split('\n').map(l => l.trim())
    const wlanNetworks = Utils.exec('iwctl station wlan0 get-networks').split('\n').map(l => l.trim().replace('>', '').replace('\u001b[0m', ''))

    ethInfoLines.splice(0, 4)
    wlanInfoLines.splice(0, 4)
    wlanNetworks.splice(0, 4)


    for (const line of ethInfoLines) {
      if (line.startsWith('Online state: '))
        networkInfo.ethernet.isConnected = !line.split(': ')[1].includes('offline')

      break
    }


    for (const line of wlanInfoLines) {
      if (line.startsWith('State')) {
        networkInfo.wifi.isConnected = !line.includes('disconnected')
      }

      if (line.startsWith('Connected network')) {
        networkInfo.wifi.name = line.split('Connected network')[1].trim()
      }
    }

    for (const line of wlanNetworks) {
      const [name] = line.split(/\s{2,}/).map(c => c.trim())

      if (name !== '') {
        networkInfo.wifi.availableNetworks.push(name)
      }

    }

    return networkInfo

  }



}

const iwd = new IWDService

export default iwd
